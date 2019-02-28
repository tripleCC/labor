require "sinatra/base"
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../errors'
require_relative '../workers'

module Labor
	class App < Sinatra::Base

		clean_options_post '/tools/clean-projects-hooks' do 
			superman_require

			names = body_params

			CleanProjectHooksWorker.perform_later(names)

			labor_response
		end
	end
end