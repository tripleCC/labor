require 'em-websocket'
require 'sinatra'
require_relative '../deploy_messager'
require_relative '../logger'

# 如果 websocket 在后台已存在 (lsof -i tcp:8081 然后 kill)，那么就无法重新连接 ws ，这会造成更新了此处代码
# 但是实际执行的是老的代码
module Labor
  module Initializer
    module Websocket
      extend Labor::Logger

      # 确保 socket server 不会因为 raise 错误而关闭
      def self.catch_logger(&block) 
        yield block if block_given?
      rescue => error
        logger.error("socket server error with #{error.message}")
      end

      def self.start_websocket_server!
        EM.run do 
          signature = EventMachine::WebSocket.start(
            :host => '0.0.0.0', 
            :port => Labor.config.websocket_port, 
            :debug => false#!Sinatra::Base.settings.production?
            ) do |ws|
            ws.onopen do |handshake|
              catch_logger do 
                query = CGI::parse(handshake.query_string)
                deploy_id = query['id']&.first

                Labor::DeployMessager.push_ws(deploy_id, ws)
                logger.info("open socket #{ws} with deploy id #{deploy_id}")
              end
            end

            ws.onmessage do |message|
              catch_logger do 
                logger.debug("receive message #{message}")
              end
            end

            ws.onclose do |event|
              catch_logger do 
                Labor::DeployMessager.pop_ws(ws)
                logger.info("close socket #{event}")
              end
            end

            ws.onerror do |error|
              catch_logger do 
                Labor::DeployMessager.pop_ws(ws)
                logger.error("socket error with #{error.message}")
              end
            end
          end
          # EM.stop_server signature
        end
      end

      Thread.new do 
        start_websocket_server!
      end
    end
  end
end