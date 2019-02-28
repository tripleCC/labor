require 'active_job'
require_relative '../models/main_deploy'
require_relative '../deploy_service'

module Labor
	class StartMainWorker < ActiveJob::Base
		queue_as :default

		def perform(id)
			deploy = MainDeploy.find(id)
			DeployService::StartMain.new(deploy).execute 
		end
	end
end

