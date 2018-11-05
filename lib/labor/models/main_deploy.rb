require 'active_record'
require 'state_machines-activerecord'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../deploy_service'
require_relative '../validations/repo_validator'
require_relative '../workers'

module Labor
  class MainDeploy < ActiveRecord::Base
  	has_many :pod_deploys, -> { order :id }, dependent: :destroy
    has_many :operations, -> { order :id }
    belongs_to :user 

    self.per_page = 15

    validates :name, presence: true
    validates :repo_url, presence: true
    validates :ref, presence: true
    validates_with Labor::RepoValidator

  	state_machine :status, :initial => :created do
      event :reset do 
        transition any => :created
      end

      event :enqueue do
        # transition any => :analyzing
        transition any - [:analyzing] => :analyzing
        # transition [:created, :canceled, :failed, :success] => :analyzing
      end

      event :deploy do
        transition [:analyzing, :failed, :canceled] => :deploying
      end

      event :success do 
        transition [:analyzing, :deploying] => :success
      end

      event :drop do
        transition [:created, :analyzing, :deploying] => :failed
        # transition any => :failed
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

      before_transition any => :failed do |deploy, transition|
        next if transition.loopback?

        transition.args.first.try do |reason|
          deploy.failure_reason = reason
        end
      end

      before_transition do |deploy, transition| 
        next if transition.loopback?
        
        # 重置 main deploy 的一些属性
        deploy.update(failure_reason: nil) unless transition.to == 'failed'
      end

      before_transition any => :canceled do |deploy, transition|
        next if transition.loopback?

        deploy.pod_deploys.each(&:cancel)
      end

      around_transition do |deploy, transition, block|
        next if transition.loopback?
        # 1
        Logger.logger.info("transition main deploy #{deploy.name} status from #{transition.from} to #{transition.to}")

        # before
        block.call
        # 2
        Labor::DeployMessager.send(deploy.id, deploy)        
        # after
      end
    end

    def retry 
      deploy
      retry_pod_deploys = pod_deploys.select(&:need_retry?)
      retry_pod_deploys.each(&:retry) if retry_pod_deploys.any?
    end

    def prepare
      DeployService::PrepareMain.new(self).execute
    end

    def start 
      DeployService::StartMain.new(self).execute 
    end

    def process
      DeployService::ProcessMain.new(self).execute
    end
  end
end