require 'active_record'
require_relative './pool'

module Labor
	module WebSocket
		class Base
			class << self 
				attr_reader :routes
				@routes = {}

		
				def on_open(path, ws, params)
					block = @routes[path]
					block.call(ws, params) if block
				end

				def on_message(ws, message)
					
				end

				protected
				def ws_open(path, &block)
					@routes[path] = block
				end

				def ws_close(path, &block)

				end
			end
		end
	end
end
# module Labor
# 	module WebSocketHandler
# 		class Base

# 			class << self
# 				# { id: [wss] }
# 				attr_reader :websockets
# 			end
# 			@websockets = {}

# 			def self.event_kind
# 				self.name.demodulize.underscore
# 			end
# 		end
# 	end
# end