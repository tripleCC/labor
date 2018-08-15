# require 'active_record'
require 'state_machines-activerecord'
require_relative '../deploy_service/prepare_pod_deploy_service'
require_relative '../deploy_service/process_pod_deploy_service'
require_relative '../deploy_service/cancel_pod_deploy_service'

module Labor
  class PodDeploy < ActiveRecord::Base
  	belongs_to :main_deploy

    # sqlite3 不支持 array 类型
    serialize :merge_request_iids
    serialize :external_dependency_names
    
  	# state_machine :status, :initial => :created do
   #    event :enqueue do
   #      transition [:created, :canceled, :failed, :success] => :analyzing
   #    end

   #    event :skip do 
   #      transition analyzing: :skipped
   #    end

   #    event :pend do
   #      transition analyzing: :pending
   #    end

   #    # reviewed 打勾，触发 auto merge (auto merge 如果出错，状态还是 pending) ，（这部分手动合并也可以接盘走后面流程） 监听 MR 状态，后更新 merged
   #    event :ready do  
   #      transition [:pending, :analyzing] => :merged
   #    end

   #    # master 分支不需要 merge
   #    event :deploy do 
   #      # 失败了重试 PL，视作 deploying
   #      transition [:merged, :pending, :failed] => :deploying
   #    end

   #    event :success do 
   #      # 两种情况
   #      # 1、正常发布 -> success
   #      transition deploying: :success
   #      # 2、标志手动发布成功 -> manual, 只有不满足 CI/CD 条件，即没有 skipped ，才可以手动发布
   #      # TODO
   #      # manual 之后，需要取消所有 PL
   #      transition skipped: :manual
   #    end

   #    event :drop do
   #      transition any - [:failed] => :failed
   #    end

   #    event :cancel do
   #      transition any - [:canceled, :success, :failed, :skipped] => :canceled
   #    end

   #    after_transition any => :merged do |deploy, transition|
   #      next if transition.loopback?
   #      # 当组件标识为已合并，则让主发布处理组件 CD
   #      deploy.main_deploy.process
   #    end

   #    after_transition any => :analyzing do |deploy, transition|
   #      next if transition.loopback?
   #      deploy.prepare
   #    end

   #    after_transition any => :deploying do |deploy, transition|
   #      next if transition.loopback?
   #      deploy.process
   #    end

   #    before_transition any => :canceled do |deploy, transition|
   #      next if transition.loopback?

   #      CancelPodDeployService.new(deploy).execute
   #    end

   #    before_transition any => :failed do |deploy, transition|
   #      transition.args.first.try do |reason|
   #        deploy.failure_reason = reason
   #      end
   #    end
   #  end

    def prepare
      PreparePodDeployService.new(self).execute
    end

   #  def process
   #    ProcessPodDeployService.new(self).execute
   #  end
  end
end