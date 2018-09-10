require 'active_job'

module Labor
	class WebSocketWorker < ActiveJob::Base
		queue_as :default

		def perform()
			p Thread.current
		end
	end
end
