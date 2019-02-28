require 'active_job'
require_relative '../deploy_service'
require_relative '../models/main_deploy'

module Labor
	class CancelMainWorker < ActiveJob::Base
		queue_as :default

		def perform(id)
			deploy = MainDeploy.find(id)
			deploy.cancel
		end
	end
end

