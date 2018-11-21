require 'http'
require_relative './config'

module Labor
	module DeployMessager
		extend Labor::Logger
		def self.send(deploy_id, hash = {})
			deploy_id = deploy_id.to_s if deploy_id.respond_to?(:to_s)
			send_message_url = "#{Labor.config.websocket_service_url}/send/labor-deploy-process/#{deploy_id}"
			result = HTTP.post(send_message_url, json: hash)
		end
	end
end