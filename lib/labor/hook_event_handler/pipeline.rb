require 'member_reminder'
require_relative './base'

module Labor
	module HookEventHandler
		class Pipeline < Base 
			include MemberReminder::DingTalk

			def handle 
				logger.info("receive project(#{object.project.name}) pipeline(id: #{object_attributes.id}, status: #{object_attributes.status}, ref: #{object_attributes.ref})")

				if object_attributes.tag
				# 组件 CD 流程 
					handle_deploy_pipeline
				else
					# 组件 MR 前的 CI 流程
					handle_merge_request_pipeline
				end
			end

			# Q 这里如果已经合并过，那么 pipeline_id 都会为空，以下代码逻辑会有问题
			# A 已经合并过的话，前面的步骤会直直接标志此发布为 merged
 			def handle_merge_request_pipeline
				deploy = PodDeploy.find_by(project_id: object.project.id, ref: object_attributes.ref, status: :pending)

				# 手动启动 PL， mr_pipeline_id 会对不上，这里去除这个查询条件
				# 如果后面需要查询的话，可以用 mr_iid 去获取 mr 对应的 PL，再对比
				# gitlab.merge_request(project.id, 1).pipeline.id
				# 不过这里多 process 几遍，问题不是很大
				# deploy = PodDeploy.find_by(project_id: object.project.id, mr_pipeline_id: object_attributes.id, ref: object_attributes.ref)
				# 成功了会走 MergeRequst 流程，这里不用管，失败了推送钉钉消息
				return if deploy.nil? #|| deploy.canceled?
				
				logger.info("handle #{deploy.name} merge request pipeline with status #{object_attributes.status}")

				# 标志为 reviewed 的情况下，才通知负责人
				if object_attributes.status == 'failed' && deploy.reviewed
					# 这里不 drop，继续 pending, 钉钉通知合并 PL 出错, 直到负责人来解决
					# GET /projects/:id/merge_requests/:merge_request_iid/pipelines | 10.5.0
					# UPDATE: 这里直接 drop 先 (issue 19、14)

					# 如果还有依赖的组件没有发布，这里 mr 的 pl 就不算错
					# 可能因为依赖组件而 lint 不过
					return if deploy.any_dependencies_unpublished?

					post_content = ''
					deploy.merge_request_iids.each do |mr_iid|
						# thread = Thread.new do 
							mr = gitlab.merge_request(deploy.project_id, mr_iid.to_s)

							# 这里 mr 获取到的 pipeline 可能是 nil 
							# 有点蛋疼
							# if object_attributes.id == mr&.pipeline&.id 
								post_content << "【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】合并 MR ( iid: #{mr_iid}, 源分支: #{mr.source_branch}, 目标分支: #{mr.target_branch}, 地址: #{mr.web_url} ) 失败, 请尽快解决\n"
							# end
						# end
						# thread
					end#.each(&:join)

					post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.owner && !post_content.length.zero?

					deploy.drop(post_content)
					#TODO
					# 如果没有依赖正在发布的组件，设置为 mr_pipeline_failed
				elsif object_attributes.status == 'success'
					#TODO
					# 设置为 mr_pipeline_success

					# 成功后执行 auto merge
					deploy.main_deploy.process
				end
			end

			def handle_deploy_pipeline
				deploy = PodDeploy.find_by(project_id: object.project.id, version: object_attributes.ref, status: :deploying)

				# 手动启动 PL， cd_pipeline_id 会对不上，这里去除这个查询条件
				# deploy = PodDeploy.find_by(project_id: object.project.id, cd_pipeline_id: object_attributes.id, version: object_attributes.ref)
				return if deploy.nil? # || deploy.canceled? 

				logger.info("handle #{deploy.name} deploy pipeline with status #{object_attributes.status}")

				case object_attributes.status
				when 'running', 'pending'		
					# 考虑到 pod deloy 失败后，CD pipeline 可能被手动启动，这里再设置一遍 deploy 状态
					deploy.deploy
				# 这里的 canceled 在 deploy 为 canceled? 时，不会执行
				when 'failed', 'canceled'#, 'skipped'
					# 凡是外界干预没有执行完全 CD pipeline，均视为失败
					# pod deloy 失败，更新 status
					post_content = "【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】发布 #{object_attributes.ref} 执行 CI 失败, 地址: #{pipeline_web_url}"
					deploy.drop(post_content)
					
					post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.owner
				when 'success'
					logger.info("pod deploy #{deploy.name} success with pipeline (id: #{object_attributes.id}, status: #{object_attributes.status}, ref: #{object_attributes.ref})")

					# pod deloy 成功，更新 status
					deploy.success
				end
			end

			def pipeline_web_url
				"#{object_attributes.project.web_url}/pipelines/#{object_attributes.id}"
			end
		end
	end
end
