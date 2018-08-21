require_relative '../hook_event_handler'

module Labor
	module HookEventHandler
		class MergeRequest < Base 
			# 1 找出 mr 对应的 pod_deploy
			# 2 看 mr 是否为 merged && mr 是否为 -> master 
			# 2.1 merged 则 设置 pod_deploy 发布为 merged
			# 2.2 main_deploy 执行 process ，发布满足条件的 deploy (merged ，并且没有需要发布的依赖)
			def handle 
				logger.info("receive project(#{object.project.name}) MR(iid: #{object_attributes.iid}, state: #{object_attributes.state}, source: #{object_attributes.source_branch}, target: #{object_attributes.target_branch})")

				deploys = PodDeploy.where(project_id: object.project.id, ref: object_attributes.source_branch)
				target_deploy = deploys.find { |deploy| deploy.merge_request_iids.include?(object_attributes.iid.to_s) }

				return unless target_deploy
				logger.info("handle pod deploy #{target_deploy.name}(#{target_deploy.id}) with MR(iid: #{object_attributes.iid}, state: #{object_attributes.state}, source: #{object_attributes.source_branch}, target: #{object_attributes.target_branch})")

				case object_attributes.state
				when 'merged' 
					# 已合并，更新 mr_iids ，删除合并的 mr_iid
					merge_request_iids = target_deploy.merge_request_iids
					merge_request_iids.delete(object_attributes.iid.to_s)
					target_deploy.update(merge_request_iids: merge_request_iids)

					if object_attributes.target_branch == 'master'
						# 如果是已合并到 master，则触发主发布处理 CD
						target_deploy.ready
					end
				when 'failed'
					puts '钉钉一波'
				end
			end
		end
	end
end
