require 'em-websocket'
require_relative '../deploy_messager'
require_relative '../logger'

Thread.new do 
  EventMachine::WebSocket.start(:host => Labor.config.host, :port => Labor.config.websocket_port, :debug => false) do |ws|
    ws.onopen do |handshake|
      query = CGI::parse(handshake.query_string)
      deploy_id = query['id']&.first

      Labor::DeployMessager.push_ws(deploy_id, ws)
      Labor::Logger.logger.info("Open socket #{ws} with deploy id #{deploy_id}")
    end

    ws.onmessage do |message|
      Labor::Logger.logger.debug("Receive message #{message}")
    end

    ws.onclose do |event|
      Labor::DeployMessager.pop_ws(ws)
      
      Labor::Logger.logger.info("Close socket #{event}")
    end

    ws.onerror do |error|
      Labor::DeployMessager.pop_ws(ws)

      Labor::Logger.logger.error("Error with #{error.message}")
    end
  end
end