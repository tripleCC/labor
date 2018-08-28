require "sinatra/base"
require 'sinatra/activerecord'
require 'sinatra/param'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../models/main_deploy'


module Labor
	class App < Sinatra::Base

		get '/deploys' do 
			# page ; per_page
			@deploys = MainDeploy.paginate(page: params[:page], per_page: params[:per_page]).order('id DESC')

			labor_response @deploys
		end

		get '/deploys/:id' do |id|
			@deploy = MainDeploy.includes(:pod_deploys).find(id)

			labor_response @deploy, [:pod_deploys]
		end

		get '/deploys/:id/pods' do |id|
			@deploy = MainDeploy.includes(:pod_deploys).find(id)

			labor_response @deploy.pod_deploys
		end

		post '/deploys' do 
			begin 
				# 可以针对同个仓库，同个分支创建发布
				@deploy = MainDeploy.create!(params)

				labor_response @deploy
			rescue ActiveRecord::RecordInvalid => error 
				logger.error "Failed to create main deploy with error #{error.message}"

				halt 400, labor_error(error.message)
			end
		end

		delete '/deploys/:id' do |id|
			@deploy = MainDeploy.find(id).destroy

			labor_response @deploy
		end

		post '/deploys/:id/pods/:pid/review' do |_, pid|
			@deploy = PodDeploy.find(pid)
			@deploy.update(reviewed: true)
			@deploy.auto_merge

			labor_response @deploy			
		end

		post '/deploys/:id/pods/:pid/manual' do |_, pid|
			@deploy = PodDeploy.find(pid)
			@deploy.update(manual: true)
			@deploy.success
			@deploy.cancel_all_operation

			labor_response @deploy
		end

		post '/deploys/:id/enqueue' do |id|
			@deploy = MainDeploy.find(id)
			@deploy.enqueue

			labor_response @deploy
		end

		post '/deploys/:id/cancel' do |id|
			@deploy = MainDeploy.find(id)
			@deploy.cancel

			labor_response @deploy
		end

		post '/deploys/:id/retry' do |id|
			@deploy = MainDeploy.find(id)
			@deploy.enqueue

			labor_response @deploy
		end
	end
end