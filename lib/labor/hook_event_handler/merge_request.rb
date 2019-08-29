require 'member_reminder'
require_relative './base'

module Labor
	module HookEventHandler
		class MergeRequest < Base 
			include MemberReminder::DingTalk

			# 1 找出 mr 对应的 pod_deploy
			# 2 看 mr 是否为 merged && mr 是否为 -> master 
			# 2.1 merged 则 设置 pod_deploy 发布为 merged
			# 2.2 main_deploy 执行 process ，发布满足条件的 deploy (merged ，并且没有需要发布的依赖)
			def handle 
				logger.info("receive project(#{object.project.name}) MR(iid: #{object_attributes.iid}, state: #{object_attributes.state}, source: #{object_attributes.source_branch}, target: #{object_attributes.target_branch})")

				deploys = PodDeploy.where(project_id: object.project.id, ref: object_attributes.source_branch, status: :pending)
				deploy = deploys.find { |deploy| deploy.merge_request_iids.include?(object_attributes.iid.to_s) }

				# Bug 日志到这里消失了，而且没有执行发布动作
				unless deploy
					logger.info("can't find deploy for merge request #{deploy.name}(#{deploy.id}) with MR(iid: #{object_attributes.iid}, state: #{object_attributes.state}, source: #{object_attributes.source_branch}, target: #{object_attributes.target_branch})")
					return 
				end
				logger.info("handle pod deploy merge request #{deploy.name}(#{deploy.id}, [#{deploy.merge_request_iids}]) with MR(iid: #{object_attributes.iid}, state: #{object_attributes.state}, source: #{object_attributes.source_branch}, target: #{object_attributes.target_branch})")

				case object_attributes.state
				when 'merged' 
					# 已合并，更新 mr_iids ，删除合并的 mr_iid
					# deploy.update(merge_request_iids: deploy.merge_request_iids.delete(object_attributes.iid.to_s))

					if object_attributes.target_branch == 'master'
						# 如果是已合并到 master，则触发主发布处理 CD
						deploy.ready
						deploy.main_deploy.process
					end
				# 这里 closed 后，移除 merge_request_iid，然后 drop
				when 'closed'
					deploy.update(merge_request_iids: deploy.merge_request_iids.delete(object_attributes.iid.to_s))
					post_content = "【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】MR #{object_attributes.iid} 已被关闭，地址: #{object_attributes.url}"
					deploy.drop(post_content)
					post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.can_push_ding?
					logger.error(post_content)
				when 'failed'
					post_content = "pod deploy #{deploy.name} 合并  #{object_attributes.source_branch} 至 #{object_attributes.target_branch} 失败，地址: #{object_attributes.url}"
					deploy.drop(post_content)
					post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.can_push_ding?
				end
			end
		end
	end
end
