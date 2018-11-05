require "sinatra/base"
require 'http'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../models/operation'
require_relative '../errors'

module Labor
	class App < Sinatra::Base

		get '/operations' do 
			keys = [:pod_deploy_id, :main_deploy_id, :user_id].map(&:to_s)
			querys = params.select { |key, value| keys.include?(key) }

			includes = [:user, :pod_deploy, :main_deploy]

			where = Operation.where(querys)
		  operations = where.paginate(page: params['page'], per_page: params['per_page']).order('id DESC').includes(includes)

		  size = where.all.size
			per_page = params[:per_page] || Operation.per_page

			labor_response operations, {
				includes: includes,
				meta: {
					total_count: size,
					per_page: per_page
				}
			}
		end
	end
end