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

			def accept_merge_request(mr_iid)
				mr = gitlab.merge_request(deploy.project_id, mr_iid.to_s)
				if mr.state == 'merged' && mr.target_branch == 'master'
					deploy.ready
				elsif !mr.merge_when_pipeline_succeeds 
					logger.info("【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】accept #{deploy.name}'s MR(#{mr_iid}) when pipeline success in pipeline webhook")
					gitlab.accept_merge_request(deploy.project_id, mr_iid)
				end
			rescue Gitlab::Error::MethodNotAllowed, 
				Gitlab::Error::BadRequest => error
				rescue_accept_merge_request(mr_iid, error)
			end

			def rescue_accept_merge_request(mr_iid, error)
				mr = gitlab.merge_request(deploy.project_id, mr_iid.to_s)
				if mr.state == 'merged' 
					# 这里有可能是因为 mr 在上次确认～accept之间被 merge 了，如果是的话，直接ready
					deploy.ready if mr.target_branch == 'master'
				elsif mr.state == 'locked'
					# locked 表示 mr 正在进行, 这里不做处理，等 mr 好了之后 webhook 会触发 merged 动作
				elsif !mr.merge_when_pipeline_succeeds && mr.merge_status == 'can_be_merged'
					# 有些需要合并的 ref 没有 stages /jobs，会导致 mr 报 400 #35, 这里直接合并，不需要 pl 成功
					gitlab.accept_merge_request(deploy.project_id, mr_iid, {})
				else
					post_content = error.message
					if mr.state == 'closed' 
						# 这里 mr closed 后，移除 merge_request_iid，然后 drop
						deploy.update(merge_request_iids: deploy.merge_request_iids.delete(mr.iid.to_s))
						post_content = "【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】MR #{mr.iid} 已被关闭，地址: #{mr.web_url}"
					elsif deploy.reviewed? # mr.merge_status == 'cannot_be_merged' 
						# pipeline 已经成功了，但是合并冲突 || 没有对应 mr，会直接走这里
						post_content = "【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】合并 MR ( iid: #{mr_iid}, state: #{mr.state}, 源分支: #{mr.source_branch}, 目标分支: #{mr.target_branch}, 地址: #{mr.web_url} ) 失败, 请确认合并是否出现冲突, 原因: #{error}"
					end

					deploy.drop(post_content)
					post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.can_push_ding? 

					logger.error("【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】fail to accept #{deploy.name}'s MR(iid: #{mr_iid}, state: #{mr.state}) with error: #{error}")
				end
			end

			def handle_merge_request_pipeline_failed 
				# 标志为 reviewed 的情况下，才通知负责人
				# 这里不 drop，继续 pending, 钉钉通知合并 PL 出错, 直到负责人来解决
					# GET /projects/:id/merge_requests/:merge_request_iid/pipelines | 10.5.0
					# UPDATE: 这里直接 drop 先 (issue 19、14)

					# 如果还有依赖的组件没有发布，这里 mr 的 pl 就不算错
					# 可能因为依赖组件而 lint 不过
				return if deploy.any_dependencies_unpublished? || !deploy.reviewed

				post_content = ''
				deploy.merge_request_iids.each do |mr_iid|
					mr = gitlab.merge_request(deploy.project_id, mr_iid.to_s)
					# 这里 mr 获取到的 pipeline 可能是 nil 
					# 有点蛋疼 | UPDATE 一旦 pl 结束，mr 的 pl 貌似就会被置 nil
					# if object_attributes.id == mr&.pipeline&.id 
						post_content << "【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】合并 MR ( iid: #{mr_iid}, 源分支: #{mr.source_branch}, 目标分支: #{mr.target_branch}, 地址: #{mr.web_url} ) 失败, 请尽快解决\n"
					# end
				end

				post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.can_push_ding? && !post_content.length.zero?

				deploy.drop(post_content)
			end

 			def handle_merge_request_pipeline
				@deploy = PodDeploy.find_by(project_id: object.project.id, ref: object_attributes.ref, status: :pending)

				# 手动启动 PL， mr_pipeline_id 会对不上，这里去除这个查询条件
				# 如果后面需要查询的话，可以用 mr_iid 去获取 mr 对应的 PL，再对比
				# gitlab.merge_request(project.id, 1).pipeline.id
				# 不过这里多 process 几遍，问题不是很大
				# deploy = PodDeploy.find_by(project_id: object.project.id, mr_pipeline_id: object_attributes.id, ref: object_attributes.ref)
				# 成功了会走 MergeRequst 流程，这里不用管，失败了推送钉钉消息
				return if deploy.nil? #|| deploy.canceled?
				
				logger.info("handle #{deploy.name} merge request pipeline with status #{object_attributes.status}")

				case object_attributes.status
				when 'running', 'pending'		
					deploy.merge_request_iids.each do |mr_iid|
						accept_merge_request(mr_iid)
					end
				when 'failed'
					handle_merge_request_pipeline_failed
				when 'success'
					# 成功后执行 auto merge
					# 这里一般 mr 会自动合并，触发住处理即可
					deploy.main_deploy.process
				end
			end

			def handle_deploy_pipeline
				# tags = Tag.includes(:pod_deploy).where(
				# 	pod_deploy: {status: :deploying}, 
				# 	sha: object_attributes.sha, 
				# 	name: object_attributes.ref, 
				# 	project_id: object.project.id
				# 	)

				# return if tags.empty?

				@deploy = PodDeploy.find_by(project_id: object.project.id, version: object_attributes.ref, status: :deploying)

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
					
					post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.can_push_ding?
				when 'success'
					logger.info("pod deploy #{deploy.name} success with pipeline (id: #{object_attributes.id}, status: #{object_attributes.status}, ref: #{object_attributes.ref})")

					# pod deloy 成功，更新 status
					deploy.success
					deploy.main_deploy.process
				end
			end

			def pipeline_web_url
				"#{project.web_url}/pipelines/#{object_attributes.id}"
			end
		end
	end
end
