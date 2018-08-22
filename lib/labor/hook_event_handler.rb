require_relative './hook_event_handler/merge_request'
require_relative './hook_event_handler/pipeline'
require_relative './hook_event_handler/push'

module Labor
	module HookEventHandler
		class << self 
			def event_kinds
				constants.map { |c| const_get(c) }.map(&:event_kind) - ['base']
			end

			def handler(event_name, hash = {}) 
				handler_cls = const_get(event_name.camelize)
				handler_cls.new(hash) if handler_cls
			end
		end
	end
end