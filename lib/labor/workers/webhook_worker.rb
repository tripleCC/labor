require 'active_job'

module Labor
	class WebhookWorker < ActiveJob::Base
		queue_as :default

		def perform(hook_string)
			hash = JSON.parse(hook_string)
			object_kind = hash['object_kind']
			if Labor::HookEventHandler.event_kinds.include?(object_kind)
				handler = Labor::HookEventHandler.handler(object_kind, hash)
				handler.handle
			end			
		end
	end
end

