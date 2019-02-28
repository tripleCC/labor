require 'active_job'
require_relative '../deploy_messager'

module Labor
	class DeployMessagerWorker < ActiveJob::Base
		queue_as :default

		def perform(deploy_id, hash)
			Labor::DeployMessager.send(deploy_id, hash)
		end
	end
end
