require 'active_record'
require 'state_machines-activerecord'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../deploy_service'
require_relative '../validations/repo_validator'
require_relative '../workers'

module Labor
  class MainDeploy < ActiveRecord::Base
  	has_many :pod_deploys, dependent: :destroy

    self.per_page = 20

    validates :name, presence: true
    validates :repo_url, presence: true
    validates :ref, presence: true
    validates_with Labor::RepoValidator

  	state_machine :status, :initial => :created do
      event :enqueue do
        transition any - [:analyzing] => :analyzing
        # transition [:created, :canceled, :failed, :success] => :analyzing
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

        # 这里去掉了可能会导致下面的 any => any 不执行，很困惑
        Logger.logger.info("after transition main deploy #{deploy.name} status from #{transition.from} to #{transition.to}")
      end

      after_transition any => :analyzing do |deploy, transition|
        next if transition.loopback?

        deploy.prepare
      end

      before_transition any => :failed do |deploy, transition|
        transition.args.first.try do |reason|
          deploy.failure_reason = reason
        end
      end

      after_transition any => any do |deploy, transition|
        next if transition.loopback?

        Labor::DeployMessager.send(deploy.id, deploy)
      end
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