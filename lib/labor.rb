require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq/api'
require 'active_job'
require "sinatra/base"
require 'sinatra/activerecord'
require 'sinatra/param'
require 'will_paginate'
require 'will_paginate/active_record'
require 'cocoapods-core'
require "gitlab"
require_relative './labor/logger'
require_relative './labor/config'
require_relative './labor/routes'
require_relative './labor/helpers'
require_relative './labor/errors'
require_relative './labor/initializers'
require_relative './labor/workers'

module Labor
	class App < Sinatra::Base
		include Labor::Logger

		register Sinatra::ActiveRecordExtension
		register WillPaginate::Sinatra

		helpers Sinatra::Param
		helpers Labor::Response
		helpers Labor::Request
		helpers Labor::Permission

		before do
	    content_type :json
	    headers 'Access-Control-Allow-Origin' => '*', 
		    'Access-Control-Allow-Headers' => 'Content-Type, Authorization', 
		    'Access-Control-Allow-Methods' => 'GET, POST, DELETE'
		end

		configure do 
			set :host, Labor.config.host
      set :port, Labor.config.port
      set :app_file, File.expand_path(__FILE__)
      enable :logging
		end

		configure :production do 
			set :raise_sinatra_param_exceptions, true
			# disable :dump_errors
      error Sinatra::Param::InvalidParameterError do
			    { error: "#{env['sinatra.error'].param} is invalid" }.to_json
			end
		end

		configure :development do
			set :show_exceptions, :after_handler
			enable :dump_errors
			# set :show_exceptions, false
      # set :raise_errors, true

      require 'better_errors'
      use BetterErrors::Middleware
      BetterErrors.application_root = settings.root

      # reloader 感觉没啥用了，对于非 labor.rb 文件改动，还是要手动重启
      require 'sinatra/reloader'
      register Sinatra::Reloader
      # Dir["#{settings.root}/labor/**/*.rb"]
      Dir["#{settings.root}/labor/*.rb"].each { |file| also_reload file }
    end

    not_found do
    	labor_error 'page not found'
    end

    # 这里如果是 webhook 阶段抛出的错误
    # 设置 error 就没用了，因为是返回给 gitlab 接口
    error Labor::Error::NotFound,
    			Gitlab::Error::NotFound do |error|
    	halt 404, labor_error(error.message)
	  end

	  error Gitlab::Error::Forbidden,
	  			Labor::Error::PermissionReject do |error|
	  	halt 403, labor_error(error.message)
	  end

	  error Gitlab::Error::Unprocessable do |error|
	  	halt 422, labor_error(error.message)
	  end

		error Gitlab::Error::Unauthorized do |error|
	  	halt 401, labor_error(error.message)
	  end

	  error Labor::Error::BadRequest,
	  			ActiveRecord::RecordNotFound,
	  			Pod::DSLError do |error|
	  	halt 400, labor_error(error.message)
	  end

	  error Labor::Error::VersionInvalid,
	  			StateMachines::InvalidTransition,
	  			SocketError,
	  			RangeError do |error|
	  	halt 500, labor_error(error.message)
	  end
	end
end
