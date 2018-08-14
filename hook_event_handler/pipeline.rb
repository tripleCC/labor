require 'member_reminder'
require_relative '../hook_event_handler'

module Labor
	module HookEventHandler
		class Pipeline < Base 
			include MemberReminder::DingTalk

			def handle 
				if object_attributes.tag
				# 组件 CD 流程 
					handle_deploy_pipeline
				else
					# 组件 MR 前的 CI 流程
					handle_merge_request_pipeline
				end
			end

			def handle_merge_request_pipeline
				deploy = PodDeploy.where(project_id: object.project.id, mr_pipeline_id: object_attributes.id, ref: object_attributes.ref)
				# 成功了会走 MergeRequst 流程，这里不用管，失败了推送钉钉消息
				return unless deploy && object_attributes.status == 'failed'
					# post_content = ""
					# post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.owner
				end
			end

			def handle_deploy_pipeline
				deploy = PodDeploy.where(project_id: object.project.id, cd_pipeline_id: object_attributes.id, version: object_attributes.ref)
				return unless deploy

				case object_attributes.status
				when 'running', 'pending'		
					# 考虑到 pod deloy 失败后，CD pipeline 可能被手动启动，这里再设置一遍 deploy 状态
					deploy.deploy
				when 'failed', 'canceled', 'skipped'
					# 凡是外界干预没有执行完全 CD pipeline，均视为失败
					# pod deloy 失败，更新 status
					deploy.drop()
				when 'success'
					# pod deloy 成功，更新 status
					deploy.success
				end
			end
		end
	end
end
