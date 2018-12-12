require 'active_job'
require_relative '../deploy_service'
require_relative '../models/pod_deploy'

module Labor
	class AutoMergePodWorker < ActiveJob::Base
		queue_as :default

		def perform(id)
			deploy = PodDeploy.find(id)
			DeployService::AutoMergePod.new(deploy).execute
		end
	end
end

