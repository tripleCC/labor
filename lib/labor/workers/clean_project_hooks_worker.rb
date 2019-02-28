require 'active_job'
require_relative '../tools'

module Labor
	class CleanProjectHooksWorker < ActiveJob::Base
		queue_as :default

		def perform(names)
			Labor::ProjectHooksCleaner.new(names).clean
		end

	end
end

