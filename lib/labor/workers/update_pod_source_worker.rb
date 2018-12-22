require 'active_job'
require_relative '../logger'
require_relative '../config'
require_relative '../external_pod/cocoapods/sources_manager'

module Labor
	class UpdatePodSourceWorker < ActiveJob::Base
		include Labor::Logger

		queue_as :default

		def perform
			logger.info("update cocoapods private source #{Labor.config.cocoapods_private_source_url}")

			Pod::Config.instance.sources_manager.default_source.update(false)
		end
	end
end

