require 'active_record'
require 'state_machines-activerecord'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../deploy_service'

module Labor
  class MainDeploy < ActiveRecord::Base
  	has_many :pod_deploys, dependent: :destroy

    self.per_page = 20

    validates :name, presence: true
    validates :repo_url, presence: true
    validates :ref, presence: true

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
      DeployService::ProcessMain.new(self).execute
    end

    def prepare
      DeployService::PrepareMain.new(self).execute
    end
  end
end