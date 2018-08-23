require "sinatra/base"
require_relative '../hook_event_handler'

module Labor
	class App < Sinatra::Base
		post '/webhook' do 
			hook_string = request.body.read
			hash = JSON.parse(hook_string)
			object_kind = hash['object_kind']
			if Labor::HookEventHandler.event_kinds.include?(object_kind)
				handler = Labor::HookEventHandler.handler(object_kind, hash)
				handler.handle
			end
		end
	end
end