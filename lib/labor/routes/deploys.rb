require "sinatra/base"
require 'sinatra/activerecord'
require 'sinatra/param'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../models/main_deploy'

module Labor
	class App < Sinatra::Base

		get '/deploys' do 
			@deploys = MainDeploy.order('id DESC').page(params[:page]).per_page(params[:page_size])

			labor_response @deploys
		end

		get '/deploys/:id' do |id|
			@deploy = MainDeploy.find(id)
			@deploy.to_json
		end

		post '/deploys' do 
			# 可以针对同个仓库，同个分支创建发布
			@deploy = MainDeploy.create(params)
		end

		delete '/deploys/:id' do |id|
			@deploy = MainDeploy.find(id).destroy
			@deploy.to_json
		end
	end
end