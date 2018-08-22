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

				deploys = PodDeploy.where(project_id: object.project.id, ref: object_attributes.source_branch)
				deploy = deploys.find { |deploy| deploy.merge_request_iids.include?(object_attributes.iid.to_s) }

				return unless deploy
				logger.info("handle pod deploy #{deploy.name}(#{deploy.id}) with MR(iid: #{object_attributes.iid}, state: #{object_attributes.state}, source: #{object_attributes.source_branch}, target: #{object_attributes.target_branch})")

				case object_attributes.state
				when 'merged' 
					# 已合并，更新 mr_iids ，删除合并的 mr_iid
					merge_request_iids = deploy.merge_request_iids
					merge_request_iids.delete(object_attributes.iid.to_s)
					deploy.update(merge_request_iids: merge_request_iids)

					if object_attributes.target_branch == 'master'
						# 如果是已合并到 master，则触发主发布处理 CD
						deploy.ready
					end
				when 'failed'
					deploy.drop
					post_content = "pod deploy #{deploy.name} 合并  #{object_attributes.source_branch} 至 #{object_attributes.target_branch} 失败，地址: #{object_attributes.url}"
					post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.owner
				end
			end
		end
	end
end
