require "sinatra/base"
require 'sinatra/activerecord'
require 'sinatra/param'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../models/main_deploy'

module Labor
	class App < Sinatra::Base

		get '/deploys' do 
			@deploys = MainDeploy.paginate(params).order('id DESC')

			labor_response @deploys
		end

		get '/deploys/:id' do |id|
			@deploy = MainDeploy.find(id)

			labor_response @deploy
		end

		post '/deploys' do 
			# 可以针对同个仓库，同个分支创建发布
			@deploy = MainDeploy.create(params)

			labor_response @deploy
		end

		delete '/deploys/:id' do |id|
			@deploy = MainDeploy.find(id).destroy

			labor_response @deploy
		end
	end
end