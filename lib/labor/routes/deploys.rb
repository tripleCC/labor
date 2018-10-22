require "sinatra/base"
require 'sinatra/activerecord'
require 'sinatra/param'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../models/main_deploy'
require_relative '../deploy_messager'
require_relative '../logger'


module Labor
	class App < Sinatra::Base
		include Labor::Logger

		# {
		# 	'page' : 1
		# 	'per_page' : 2
		# }
		get '/deploys' do 
			# page ; per_page
			@deploys = MainDeploy.paginate(page: params[:page], per_page: params[:per_page]).order('id DESC')
			@size = MainDeploy.all.size
			@per_page = params[:per_page] || MainDeploy.per_page

			labor_response @deploys, {
				meta: {
					total_count: @size,
					per_page: @per_page
				}
			}
		end

		get '/deploys/:id' do |id|
			@deploy = MainDeploy.includes(:pod_deploys).find(id)

			labor_response @deploy, {
				includes: [:pod_deploys]
			}
		end

		get '/deploys/:id/pods' do |id|
			@deploy = MainDeploy.includes(:pod_deploys).find(id)

			labor_response @deploy.pod_deploys
		end

		# {
		# 	'name' : xxxx
		# 	'repo_url' : gitxxx
		# 	'ref' : releasexxx
		# }
		options '/deploys' do 
		end
		post '/deploys' do 
			begin 
				request.body.rewind
				params = JSON.parse(request.body.read)
				# 可以针对同个仓库，同个分支创建发布
				@deploy = MainDeploy.create!(params)

				labor_response @deploy
			rescue ActiveRecord::RecordInvalid => error 
				logger.error "Failed to create main deploy with error #{error.message}, params #{params}"

				halt 400, labor_error(error.message)
			end
		end

		options '/deploys/:id' do 
		end
		delete '/deploys/:id' do |id|
			@deploy = MainDeploy.find(id).destroy
			@deploy.cancel

			labor_response @deploy
		end

		post '/deploys/:id/cancel' do |id|
			@deploy = MainDeploy.find(id)
			@deploy.cancel

			labor_response @deploy
		end
		
		# {
		# 	'pid' : version
		# }
		# 处理跨域预检请求
		options '/deploys/pods/versions/update' do 
		end
		post '/deploys/pods/versions/update' do
			request.body.rewind
			params = JSON.parse(request.body.read)
			pids = params.keys.map(&:to_i)
			pod_deploys = pids.map do |pid|
				pod_deploy = PodDeploy.find(pid)
				pod_deploy.update(:version => params[pid.to_s])
				pod_deploy
			end

			labor_response pod_deploys
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

		post '/deploys/:id/pods/:pid/retry' do |_, pid|
			@deploy = PodDeploy.find(pid)
			@deploy.cancel
			# 和 main deploy 不同，这里 retry 走的是 enqueue，重新更新 spec，发起 MR
			@deploy.retry

			labor_response @deploy
		end

		post '/deploys/:id/pods/:pid/cancel' do |_, pid|
			@deploy = PodDeploy.find(pid)
			@deploy.cancel

			labor_response @deploy
		end

		post '/deploys/:id/enqueue' do |id|
			@deploy = MainDeploy.find(id)
			@deploy.reset
			@deploy.enqueue

			@deploy.start if params[:start_directly]

			labor_response @deploy
		end		

		post '/deploys/:id/deploy' do |id|
			@deploy = MainDeploy.find(id)
			@deploy.start

			labor_response @deploy
		end		

		post '/deploys/:id/cancel' do |id|
			@deploy = MainDeploy.find(id)
			@deploy.cancel

			labor_response @deploy
		end

		post '/deploys/:id/retry' do |id|
			@deploy = MainDeploy.includes(:pod_deploys).find(id)

			failed_pod_deploys = @deploy.pod_deploys.select(&:failed?)
			if failed_pod_deploys.any?
				failed_pod_deploys.each(&:retry)
			else 
				# 和 pod deploy 不同，这里 retry 走的是 deloy，不重新分析，否则所有的 pod deploy 会回归 created 状态
				@deploy.retry
			end
			# if @deploy.pod_deploys

			labor_response @deploy
		end
	end
end