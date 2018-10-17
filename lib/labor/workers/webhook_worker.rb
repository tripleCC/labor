require 'active_job'
require_relative '../hook_event_handler'

module Labor
	class WebhookWorker < ActiveJob::Base
		queue_as :default

		def perform(hash)
			object_kind = hash['object_kind']
			if Labor::HookEventHandler.event_kinds.include?(object_kind)
				handler = Labor::HookEventHandler.handler(object_kind, hash)
				handler.handle
			end			
		end
	end
end

