require 'em-websocket'
require_relative '../deploy_messager'
require_relative '../logger'

# 如果 websocket 在后台已存在 (lsof -i tcp:8081 然后 kill)，那么就无法重新连接 ws ，这会造成更新了此处代码
# 但是实际执行的是老的代码

Thread.new do 
  EM.run do 
    signature = EventMachine::WebSocket.start(:host => Labor.config.host, :port => Labor.config.websocket_port, :debug => false) do |ws|
      ws.onopen do |handshake|
        query = CGI::parse(handshake.query_string)
        deploy_id = query['id']&.first

        Labor::DeployMessager.push_ws(deploy_id, ws)
        Labor::Logger.logger.info("open socket #{ws} with deploy id #{deploy_id}")
      end

      ws.onmessage do |message|
        Labor::Logger.logger.debug("receive message #{message}")
      end

      ws.onclose do |event|
        Labor::DeployMessager.pop_ws(ws)
        
        Labor::Logger.logger.info("close socket #{event}")
      end

      ws.onerror do |error|
        Labor::DeployMessager.pop_ws(ws)

        Labor::Logger.logger.error("socket error with #{error.message}")
      end
    end
  end
end