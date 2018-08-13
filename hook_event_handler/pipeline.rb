require_relative '../hook_event_handler'

module Labor
	module HookEventHandler
		class Pipeline < Base 
			def handle 
				p object_attributes.status == 'failed'
				object_attributes.id
				object_attributes.ref 
			end
		end
	end
end
