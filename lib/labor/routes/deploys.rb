require "sinatra/base"
require 'sinatra/activerecord'
require 'sinatra/param'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../models/main_deploy'

module Labor
	class App < Sinatra::Base

		# {
# 	data: [],
# 	errors: [],
# 	meta: {}
# }

		get '/deploys' do 
			@deploys = MainDeploy.paginate(page: params[:page])
			@deploys.to_json
		end

		get '/deploys/:id' do |id|
			@deploy = MainDeploy.find(id)
			@deploy.to_json
		end

		post '/deploys' do 
			# 可以针对同个仓库，同个分支创建发布
			@deploy = MainDeploy.create(params)
			@deploy.to_json
		end

		delete '/deploys/:id' do |id|
			@deploy = MainDeploy.find(id).destroy
			@deploy.to_json
		end
	end
end