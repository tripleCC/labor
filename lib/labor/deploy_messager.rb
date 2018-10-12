require 'em-websocket'
require_relative './config'
require_relative './logger'

module Labor
	module DeployMessager
		extend Labor::Logger

		class << self 
			attr_reader :websockets
		end
		@ws_lock = Mutex.new
		@websockets = {}

		def self.send(deploy_id, hash = {})
			deploy_id = deploy_id.to_s if deploy_id.respond_to?(:to_s)
			wss = websockets[deploy_id]
			hash = hash.to_json unless hash.is_a?(JSON)
			logger.info("send ws message to #{deploy_id}, message: #{hash}")

			wss.each do |ws|
				ws.send(hash)
			end if wss
		end

		def self.push_ws(deploy_id, ws)
			@ws_lock.synchronize {
				websockets[deploy_id] ||= [] 
        websockets[deploy_id] << ws
        logger.info("push ws #{ws} for #{deploy_id}")
    	}
		end

		def self.pop_ws(ws)
			@ws_lock.synchronize {
				websockets.each do |id, wss|
          wss.reject! { |w| w == ws }
        end
        logger.info("pop ws #{ws}")
      }
		end
	end
end