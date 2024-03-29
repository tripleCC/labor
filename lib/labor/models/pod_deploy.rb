require 'active_record'
require 'state_machines-activerecord'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../deploy_service'
require_relative '../workers'
require_relative '../logger'
require_relative './project'
require_relative './merge_request'
require_relative './tag'
require_relative './pipeline'

module Labor
  class PodDeploy < ActiveRecord::Base
    has_many :tags, -> { distinct }, dependent: :destroy
    has_many :merge_requests, -> { distinct }, dependent: :destroy
    has_many :pipelines, -> { distinct }, dependent: :destroy
  	belongs_to :main_deploy
    belongs_to :project
    belongs_to :user

    # scope with_tags -> (query) { join(:tags).where(tags: query) }

    # before_create :set_project
    # sqlite3 不支持 array 类型
    # serialize :merge_request_iids
    # serialize :external_dependency_names

    # scope :need_retry, -> { failed? || canceled? || skipped? }

    delegate :should_push_ding, to: :main_deploy, prefix: true, allow_nil: true

    self.per_page = 30

    validates :repo_url, presence: true

  	state_machine :status, :initial => :created do
      event :enqueue do
        transition [:created, :canceled, :failed, :success, :skipped] => :preparing
      end

      event :skip do 
        transition preparing: :skipped
      end

      event :pend do
        transition preparing: :pending
      end

      # reviewed 打勾，触发 auto merge (auto merge 如果出错，状态还是 pending) ，（这部分手动合并也可以接盘走后面流程） 监听 MR 状态，后更新 merged
      # 这里 ready 之后，如果想直接发布，需要手动调用 deploy.main_deploy.process
      # 否则直接在 ready after_transition 里面执行 deploy.main_deploy.process ，会让后面的 deploy 重复执行 auto_merge
      # 程序卡死
      event :ready do  
        transition [:pending, :preparing] => :merged
      end

      # master 分支不需要 merge
      event :deploy do 
        # 失败了重试 PL，视作 deploying
        transition [:merged, :pending, :failed] => :deploying
      end

      event :success do 
        # transition deploying: :success
        transition any - [:success] => :success
      end

      event :drop do
        # 成功后，不能立刻失败
        # 网页标志以打包，success；之后 cancel ，pl 会返回 canceled，导致执行 drop
        transition any - [:failed, :success] => :failed
      end

      event :cancel do
        transition any - [:canceled, :success, :failed, :skipped] => :canceled
      end

      # after_transition any => [:success] do |deploy, transition|
      #   next if transition.loopback?
      #   # 让主发布轮询处理下个组件
      #   deploy.main_deploy.process
      # end

      after_transition any => :preparing do |deploy, transition|
        next if transition.loopback?
        deploy.prepare
      end

      before_transition any => :canceled do |deploy, transition|
        next if transition.loopback?
        deploy.cancel_all_operation
      end

      before_transition any => :failed do |deploy, transition|
        next if transition.loopback?
        transition.args.first.try do |reason|
          deploy.failure_reason = reason
        end
      end

      # pod deploy 失败和 main deploy 拆开
      # after_transition any => :failed do |deploy, transition|
      #   next if transition.loopback?
      #   deploy.main_deploy.drop([deploy.main_deploy.failure_reason, deploy.failure_reason].compact.join(', '))
      # end

      before_transition do |deploy, transition| 
        next if transition.loopback?
        deploy.update(failure_reason: nil) unless transition.to == 'failed'
      end

      around_transition do |deploy, transition, block|
        next if transition.loopback?
        # 1
        Logger.logger.info("transition pod deploy #{deploy.name} status from #{transition.from} to #{transition.to}")
        # before
        block.call
        # 2
        # DeployMessagerWorker.perform_later(deploy.main_deploy.id, deploy.to_json)
        Labor::DeployMessager.send(deploy.main_deploy.id, deploy)     
        # after
      end
    end

    def retry 
      enqueue
      # pod deploy 重试，main deploy 不展示 deploying 了
      # 因为 pod deploy 失败和 main deploy 拆开了
      # if main_deploy.can_deploy? 
      #   main_deploy.deploy
      # else
      main_deploy.process 
      # end
    end

    def any_dependencies_unpublished?
      left_pod_deploy_names = main_deploy.pod_deploys.reject(&:success?).map(&:name)
      (external_dependency_names & left_pod_deploy_names).any?
    end

    def need_retry?
      failed? || canceled? || skipped?
    end

    def can_push_ding?
      false
      # main_deploy_should_push_ding && owner
    end

    def cancel_all_operation
      CancelPodWorker.perform_later(id)
    end

    def prepare
      # PreparePodWorker.perform_later(id)
      DeployService::PreparePod.new(self).execute
    end

    def process
      deploy
      ProcessPodWorker.perform_later(id)
    end

    def auto_merge
      # AutoMergePodWorker.perform_later(id)
      DeployService::AutoMergePod.new(self).execute
    end

    private
  end
end