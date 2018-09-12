require 'em-websocket'
require_relative './config'

module Labor
	module DeployMessager

		class << self 
			attr_reader :websockets
		end
		@ws_lock = Mutex.new
		@websockets = {}

		def self.send(deploy_id, hash = {})
			wss = websockets[deploy_id]
			p wss
			wss.each do |ws|
				ws.send(hash.to_json)
			end if wss
		end

		def self.push_ws(deploy_id, ws)
			@ws_lock.synchronize {
				websockets[deploy_id] ||= [] 
        websockets[deploy_id] << ws
    	}
		end

		def self.pop_ws(ws)
			@ws_lock.synchronize {
				websockets.each do |id, wss|
          wss.reject! { |w| w == ws }
        end
      }
		end
	end
end