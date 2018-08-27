require 'member_reminder'
require_relative './base'

module Labor
	module HookEventHandler
		class Pipeline < Base 
			include MemberReminder::DingTalk

			def handle 
				logger.info("receive project(#{object.project.name}) pipeline(id: #{object_attributes.id}, status: #{object_attributes.status}, ref: #{object_attributes.ref}")

				if object_attributes.tag
				# 组件 CD 流程 
					handle_deploy_pipeline
				else
					# 组件 MR 前的 CI 流程
					handle_merge_request_pipeline
				end
			end

			# TODO 这里如果已经合并过，那么 pipeline_id 都会为空，以下代码逻辑会有问题
 			def handle_merge_request_pipeline
				deploy = PodDeploy.find_by(project_id: object.project.id, mr_pipeline_id: object_attributes.id, ref: object_attributes.ref)
				# 成功了会走 MergeRequst 流程，这里不用管，失败了推送钉钉消息
				return unless deploy 
				logger.info("handle deploy #{deploy.name} pipeline with status #{object_attributes.status}")

				if object_attributes.status == 'failed'
					# 这里不 drop，继续 pending ，直到负责人来解决
					post_content = "pod deploy #{deploy.name} 合并 MR (#{object_attributes.ref}) 必须通过的 CI 执行失败, 地址: #{pipeline_web_url}"
					post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.owner
				end
			end

			def handle_deploy_pipeline
				deploy = PodDeploy.find_by(project_id: object.project.id, cd_pipeline_id: object_attributes.id, version: object_attributes.ref)
				return unless deploy

				case object_attributes.status
				when 'running', 'pending'		
					# 考虑到 pod deloy 失败后，CD pipeline 可能被手动启动，这里再设置一遍 deploy 状态
					deploy.deploy
				when 'failed', 'canceled', 'skipped'
					# 凡是外界干预没有执行完全 CD pipeline，均视为失败
					# pod deloy 失败，更新 status
					deploy.drop()
					post_content = "pod deploy #{deploy.name} 发布 #{object_attributes.ref} 执行 CD 失败, 地址: #{pipeline_web_url}"
					post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.owner
				when 'success'
					# pod deloy 成功，更新 status
					deploy.success
				end
			end

			def pipeline_web_url
				"#{object_attributes.web_url}/pipelines/#{object_attributes.id}"
			end
		end
	end
end
