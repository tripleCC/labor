require 'active_record'
require 'state_machines-activerecord'
require_relative '../deploy_service/prepare_main_deploy_service'
require_relative '../deploy_service/process_main_deploy_service'

module Labor
  class MainDeploy < ActiveRecord::Base
  	has_many :pod_deploys, dependent: :destroy

  	state_machine :status, :initial => :created do
      event :enqueue do
        transition [:created, :canceled, :failed, :success] => :analyzing
      end

      event :deploy do
        transition analyzing: :deploying
      end

      event :success do 
        transition deploying: :success
      end

      event :drop do
        transition [:created, :analyzing, :deploying] => :failed
      end

      event :cancel do
        transition [:created, :analyzing, :deploying] => :canceled
      end

      after_transition any => :deploying do |deploy, transition|
        next if transition.loopback?
        deploy.process
      end

      after_transition any => :analyzing do |deploy, transition|
        next if transition.loopback?
        deploy.prepare
      end
    end

    def process
      ProcessMainDeployService.new(self).execute
    end

    def prepare
      PrepareMainDeployService.new(self).execute
    end
  end
end