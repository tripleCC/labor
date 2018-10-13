require "sinatra/base"
require_relative '../hook_event_handler'
require_relative '../workers'

module Labor
	class App < Sinatra::Base
		post '/webhook' do 
			hook_string = request.body.read
			WebhookWorker.perform_later(hook_string)
			# hash = JSON.parse(hook_string)
			# object_kind = hash['object_kind']
			# if Labor::HookEventHandler.event_kinds.include?(object_kind)
			# 	handler = Labor::HookEventHandler.handler(object_kind, hash)
			# 	handler.handle
			# end	
			# labor_response 
		end
	end
end