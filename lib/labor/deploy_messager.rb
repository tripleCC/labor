require 'http'
require_relative './helpers/response'
require_relative './config'

module Labor
	module DeployMessager
		extend Labor::Logger
		extend Labor::Response
		# type main or pod
		def self.send(deploy_id, hash = {}, type = :pod)

			deploy_id = deploy_id.to_s if deploy_id.respond_to?(:to_s)
			send_message_url = "#{Labor.config.websocket_service_url}/send/labor-deploy-process/#{deploy_id}"
			json = labor_raw_response hash, {
				meta: {
					type: type
				}
			}

			result = HTTP.post(send_message_url, json: json)
		end
	end
end