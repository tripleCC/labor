require "sinatra/base"
require 'sinatra/activerecord'
require 'sinatra/param'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../models/main_deploy'
require_relative '../models/user'
require_relative '../models/operation'
require_relative '../deploy_messager'
require_relative '../logger'
require_relative '../remote_file'


module Labor
	class App < Sinatra::Base
		include Labor::Logger

		# {
		# 	'page' : 1
		# 	'per_page' : 2
		# }
		clean_options_get '/deploys' do 
			# page ; per_page
			@deploys = MainDeploy.includes(:user).paginate(page: params['page'], per_page: params['per_page']).order('id DESC')
			@size = MainDeploy.all.size
			@per_page = params[:per_page] || MainDeploy.per_page

			labor_response @deploys, {
				includes: [
					:user
				],
				meta: {
					total_count: @size,
					per_page: @per_page
				}
			}
		end

		# get 'deploys/:id/operations' do |id|
		# 	deploy = MainDeploy.includes(:operations).find(id)

		# 	labor_response deploy.operations
		# end

		clean_options_get '/deploys/:id' do |id|
			@deploy = MainDeploy.includes(:user, :pod_deploys => :user).find(id)

			labor_response @deploy, {
				includes: [
					:user,
					{ 
						pod_deploys: {
							include: :user
						}
					}
				]
			}
		end

		# {
		# 	'name' : xxxx
		# 	'repo_url' : gitxxx
		# 	'ref' : releasexxx
		#   'user_id' : xxxx
		# }
		clean_options_post '/deploys' do 
			begin 
				params = body_params

				# 可以针对同个仓库，同个分支创建发布
				user = User.find(auth_user_id)
				
				@deploy = MainDeploy.create!({ 
					name: params['name'], 
					repo_url: params['repo_url'],  
					ref: params['ref'],  
					should_push_ding: params['should_push_ding'],
					user: user 
					})

				labor_response @deploy
			rescue ActiveRecord::RecordInvalid => error 
				logger.error "Failed to create main deploy with error #{error.message}, params #{params}"

				halt 400, labor_error(error.message)
			end
		end

		clean_options_post '/deploys/:id/podfile/update' do
			deploy = MainDeploy.find(id)

			permission_require(deploy, :update_podfile)

			podfile = Labor::RemoteFile::Podfile.new(deploy.project_id, deploy.ref)
			versions = deploy.pod_deploys.map { |pod_deploy| [pod_deploy.name, pod_deploy.version] }.to_h
			podfile.edit_remote(versions)

			labor_response versions
		end

		clean_options_post '/deploys/:id/delete' do |id|
			deploy = MainDeploy.find(id)

			permission_require(deploy, :delete)

			deploy.cancel
			deploy.destroy

			labor_response deploy
		end

		clean_options_post '/deploys/:id/cancel' do |id|
			deploy = MainDeploy.find(id)

			permission_require(deploy, :cancel)

			deploy.cancel

			labor_response deploy
		end
		
		# {
		# 	'pid' : version
		# }
		# 处理跨域预检请求
		# options '/deploys/:id/pods/versions/update' do 
		# end
		# post '/deploys/:id/pods/versions/update' do |id|
		# 	deploy = MainDeploy.find(id)

		# 	permission_require(deploy, :update_versions)

		# 	versions = body_params
		# 	pids = versions.keys.map(&:to_i)
		# 	pod_deploys = pids.map do |pid|
		# 		pod_deploy = PodDeploy.find(pid)
		# 		pod_deploy.update(:version => versions[pid.to_s])
		# 		pod_deploy
		# 	end

		# 	labor_response pod_deploys
		# end

		clean_options_post '/deploys/pods/versions/update' do
			versions = body_params
			pids = versions.keys.map(&:to_i)
			pod_deploys = pids.map { |pid| PodDeploy.find(pid) }
			pod_deploys.each { |deploy| permission_require(deploy, :update_version) }

			pod_deploys.each do |pod_deploy|
				pod_deploy.update(:version => versions[pod_deploy.id.to_s])
			end

			labor_response pod_deploys
		end

		clean_options_post '/deploys/:id/pods/:pid/review' do |_, pid|
			deploy = PodDeploy.find(pid)

			permission_require(deploy, :review)

			deploy.update(reviewed: true)

			deploy.main_deploy.process
			# @deploy.auto_merge 

			labor_response deploy			
		end

		clean_options_post '/deploys/:id/pods/:pid/manual' do |_, pid|
			deploy = PodDeploy.find(pid)

			permission_require(deploy, :manual)

			deploy.update(manual: true)
			deploy.success
			deploy.cancel_all_operation
			deploy.main_deploy.process

			labor_response deploy
		end

		clean_options_post '/deploys/:id/pods/:pid/enqueue' do |_, pid|
			deploy = PodDeploy.find(pid)

			permission_require(deploy, :enqueue)

			deploy.enqueue
			deploy.main_deploy.process

			labor_response deploy
		end

		clean_options_post '/deploys/:id/pods/:pid/retry' do |_, pid|
			deploy = PodDeploy.find(pid)

			permission_require(deploy, :retry)

			deploy.cancel
			# 和 main deploy 不同，这里 retry 走的是 enqueue，重新更新 spec，发起 MR
			deploy.retry

			labor_response deploy
		end

		clean_options_post '/deploys/:id/pods/:pid/cancel' do |_, pid|
			deploy = PodDeploy.find(pid)

			permission_require(deploy, :cancel)

			deploy.cancel

			labor_response deploy
		end

		clean_options_post '/deploys/:id/enqueue' do |id|
			deploy = MainDeploy.find(id)

			permission_require(deploy, :enqueue)

			deploy.reset
			deploy.enqueue

			deploy.start if params[:start_directly]

			labor_response deploy
		end		

		clean_options_post '/deploys/:id/deploy' do |id|
			deploy = MainDeploy.find(id)

			permission_require(deploy, :deploy)

			deploy.start

			labor_response deploy
		end		

		clean_options_post '/deploys/:id/cancel' do |id|
			deploy = MainDeploy.find(id)

			permission_require(deploy, :cancel)

			deploy.cancel

			labor_response deploy
		end

		clean_options_post '/deploys/:id/retry' do |id|
			deploy = MainDeploy.includes(:pod_deploys).find(id)

			permission_require(deploy, :retry)

			# 和 pod deploy 不同，这里 retry 走的是 deloy，不重新分析，否则所有的 pod deploy 会回归 created 状态
			deploy.retry
			# if @deploy.pod_deploys

			labor_response deploy
		end
	end
end