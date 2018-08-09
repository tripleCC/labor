require 'active_record'
require 'state_machines-activerecord'
require_relative '../deploy_service/prepare_pod_deploy_service'
require_relative '../deploy_service/process_pod_deploy_service'

module Labor
  class PodDeploy < ActiveRecord::Base
  	belongs_to :main_deploy

  	state_machine :status, :initial => :created do
      event :enqueue do
        transition [:created, :canceled, :failed, :success] => :analyzing
      end

      event :skip do 
        transition analyzing: :skipped
      end

      event :pend do
        transition analyzing: :pending
      end

      # reviewed 打勾，触发 auto merge (auto merge 如果出错，状态还是 pending) ，（这部分手动合并也可以接盘走后面流程） 监听 MR 状态，后更新 merged
      event :merge do  
        transition pending: :merged
      end

      # master 分支不需要 merge
      event :deploy do 
        transition [:merged, :pending] => :deploying
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
    end

    def prepare
      PreparePodDeployService.new(self).execute
    end

    def process
      ProcessPodDeployService.new(self).execute
    end


    # sqlite3 不支持 array 类型
    def set_merge_request_iids(iids)
      self.merge_request_iids = iids.join('|')
    end

    def add_merge_request_iid(iid)
      iids = get_merge_request_iids
      iids << iid
      self.merge_request_iids = iids.join('|')
    end

    def delete_merge_request_iid(iid)
      iids = get_merge_request_iids
      iids.delete(iid)
      self.merge_request_iids = iids.join('|')
    end

    def get_merge_request_iids
      iids_string = merge_request_iids
      iids = iids_string.split('|') if iids_string
      iids || []
    end
  end
end