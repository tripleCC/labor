require 'member_reminder'
require "sinatra/base"
require 'http'
require 'will_paginate'
require 'will_paginate/active_record'
require 'will_paginate/array'
require_relative '../models/specification'
require_relative '../errors'


module Labor
	class App < Sinatra::Base

		clean_options_post '/specifications' do 
			begin 
				params = body_params

				keys = [:name, :version, :source, :owner, :team, :platform_type].map(&:to_s)
				params = params.select { |key, value| keys.include?(key) && value.present? }
				
				spec = Labor::Specification.create_or_update_specification_by(params)

				labor_response spec
			rescue ActiveRecord::RecordInvalid => error 
				logger.error "Failed to create or update spec with error #{error.message}, params #{params}"

				halt 400, labor_error(error.message)
			end
		end
	end
end