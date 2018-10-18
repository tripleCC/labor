require 'active_record'
require 'state_machines-activerecord'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../deploy_service'
require_relative '../workers'
require_relative '../logger'

module Labor
  class PodDeploy < ActiveRecord::Base
  	belongs_to :main_deploy

    # sqlite3 不支持 array 类型
    # serialize :merge_request_iids
    # serialize :external_dependency_names

    self.per_page = 30

    validates :repo_url, presence: true

  	state_machine :status, :initial => :created do
      event :enqueue do
        # transition any - [:analyzing] => :analyzing
        transition [:created, :canceled, :failed, :success, :skipped] => :analyzing
      end

      event :skip do 
        transition analyzing: :skipped
      end

      event :pend do
        transition analyzing: :pending
      end

      # reviewed 打勾，触发 auto merge (auto merge 如果出错，状态还是 pending) ，（这部分手动合并也可以接盘走后面流程） 监听 MR 状态，后更新 merged
      event :ready do  
        transition [:pending, :analyzing] => :merged
      end

      # master 分支不需要 merge
      event :deploy do 
        # 失败了重试 PL，视作 deploying
        transition [:merged, :pending, :failed] => :deploying
      end

      event :success do 
        transition deploying: :success
      end

      event :drop do
        transition any - [:failed] => :failed
      end

      event :cancel do
        transition any - [:canceled, :success, :failed, :skipped] => :canceled
      end

      after_transition any => [:merged, :success] do |deploy, transition|
        next if transition.loopback?
        # 当组件标识为已合并，则让主发布处理组件 CD
        deploy.main_deploy.process

        # 这里去掉了可能会导致下面的 any => any 不执行，很困惑
        Logger.logger.info("after transition pod deploy #{deploy.name} status from #{transition.from} to #{transition.to}")
      end

      after_transition any => :analyzing do |deploy, transition|
        next if transition.loopback?
        deploy.prepare
      end

      after_transition any => :deploying do |deploy, transition|
        next if transition.loopback?
        deploy.process
      end

      before_transition any => :canceled do |deploy, transition|
        next if transition.loopback?
        deploy.cancel_all_operation
      end

      before_transition any => :failed do |deploy, transition|
        transition.args.first.try do |reason|
          deploy.failure_reason = reason
        end
      end

      after_transition any => any do |deploy, transition|
        next if transition.loopback?

        # DeployMessagerWorker.perform_later(deploy.main_deploy.id, deploy.to_json)
        Labor::DeployMessager.send(deploy.main_deploy.id, deploy)
      end
    end

    def cancel_all_operation
      DeployService::CancelPod.new(self).execute 
    end

    def prepare
      DeployService::PreparePod.new(self).execute
    end

    def process
      DeployService::ProcessPod.new(self).execute
    end

    def auto_merge
      DeployService::AutoMergePod.new(self).execute
    end
  end
end