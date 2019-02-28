require "sinatra/base"
require_relative '../hook_event_handler'
require_relative '../workers'
require_relative '../deploy_service'
require_relative '../external_pod/cocoapods/sources_manager'
require_relative '../config'

module Labor
	class App < Sinatra::Base
		post '/webhook' do 
			# WebhookWorker.perform_later(hook_string)
			hash = body_params
			object_kind = hash['object_kind']
			if Labor::HookEventHandler.event_kinds.include?(object_kind)
				handler = Labor::HookEventHandler.handler(object_kind, hash)
				handler.handle
			end	
			labor_response 
		end

		post '/webhook/cocoapods' do 
			hash = body_params
			object_kind = hash['object_kind']
			if object_kind == 'push'
				Labor::Source::Updater.update
				UpdatePodSourceWorker.perform_later(hash)
			end

			labor_response
		end
	end
end