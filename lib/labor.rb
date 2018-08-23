require "sinatra/base"
require 'sinatra/activerecord'
require 'sinatra/param'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative './labor/config'
require_relative './labor/routes'

module Labor
	class App < Sinatra::Base
		register Sinatra::ActiveRecordExtension
		register WillPaginate::Sinatra

		helpers Sinatra::Param

		before do
	    content_type :json
		end

		configure do 
			set :host, Labor.config.host
      set :port, Labor.config.port
      enable :dump_errors, :logging
		end

		configure :production do 
			set :raise_sinatra_param_exceptions, true
      error Sinatra::Param::InvalidParameterError do
			    { error: "#{env['sinatra.error'].param} is invalid" }.to_json
			end
		end

		configure :development do
			# set :show_exceptions, false
      # set :raise_errors, true

      require 'better_errors'
      use BetterErrors::Middleware
      BetterErrors.application_root = settings.root

      require 'sinatra/reloader'
      register Sinatra::Reloader
      Dir["#{settings.root}/labor/*.rb"].each { |file| also_reload file }
    end
	end
end