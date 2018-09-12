require_relative './base'

module Labor
	module WebSocket
		class App < Base 
			ws '/deploy/status' do |ws, params|
				
			end
		end
	end
end