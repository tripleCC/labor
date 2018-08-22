require 'sinatra/activerecord'
require_relative './labor/models/pod_deploy'
require_relative './labor/models/main_deploy'
require_relative './labor/hook_event_handler'
require_relative './labor/config'

module Labor
	class App < Sinatra::Base
		register Sinatra::ActiveRecordExtension

		configure do 
			set :host, Labor.config.host
      set :port, Labor.config.port
      enable :dump_errors, :logging
		end

		configure :development do
      require 'better_errors'
      use BetterErrors::Middleware
      BetterErrors.application_root = settings.root

      require 'sinatra/reloader'
      register Sinatra::Reloader
      Dir["#{settings.root}/labor/*.rb"].each { |file| also_reload file }
    end

		get '/deploys' do 
			PodDeploy.all.each(&:destroy)
			MainDeploy.all.each(&:destroy)
			main_deploy = MainDeploy.find_or_create_by(
				name: '发布1.6.5', 
				repo_url: 'git@git.2dfire-inc.com:qingmu/PodE.git', 
				ref: 'release/0.0.1'
				)

			main_deploy.enqueue
			''
		end

		post '/webhook' do 
			hook_string = request.body.read
			hash = JSON.parse(hook_string)
			# pp hash
			object_kind = hash['object_kind']

			if Labor::HookEventHandler.event_kinds.include?(object_kind)
				handler = Labor::HookEventHandler.handler(object_kind, hash)
				handler.handle
			end
		end

	end
end