module Labor
	module Handler
		def event_kinds
			constants.map { |c| const_get(c) }.map(&:event_kind) - ['base']
		end

		def handler(event_name, hash = {}) 
			handler_cls = const_get(event_name.camelize)
			handler_cls.new(hash) if handler_cls
		end
	end
end