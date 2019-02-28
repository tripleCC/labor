require 'active_job'
require_relative '../logger'
require_relative '../config'
require_relative '../models/specification'

module Labor
	class UpdatePodSourceWorker < ActiveJob::Base
		include Labor::Logger

		queue_as :default

		def perform(object)
			Labor::Specification.update_or_delete_by_webhook_object(object)
		end
	end
end

