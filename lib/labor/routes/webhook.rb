require "sinatra/base"
require_relative '../hook_event_handler'
require_relative '../workers'

module Labor
	class App < Sinatra::Base
		post '/webhook' do 
			hook_string = request.body.read
			WebhookWorker.perform_later(hook_string)
			labor_response 
		end
	end
end