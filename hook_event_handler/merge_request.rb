require_relative '../hook_event_handler'

module Labor
	module HookEventHandler
		class MergeRequest < Base 
			# 1 找出 mr 对应的 pod_deploy
			# 2 看 mr 是否为 merged && mr 是否为 -> master 
			# 2.1 merged 则 设置 pod_deploy 发布为 merged
			# 2.2 main_deploy 执行 process ，发布满足条件的 deploy (merged ，并且没有需要发布的依赖)
			def handle 
				deploys = PodDeploy.where(project_id: object.project.id, ref: object.object_attributes.source.default_branch)
				target_deploy = deploys.find { |deploy| deploy.merge_request_iids.include?(object.object_attributes.iid) }

				return unless target_deploy
				logger.info("handle pod deploy #{target_deploy.name} with MR(iid: #{object.object_attributes.iid}, state: #{object.object_attributes.state}, source: #{object.object_attributes.source.default_branch}, target: #{object.object_attributes.target.default_branch})")

				if object.object_attributes.state == 'merged' 
					# 已合并，更新 mr_iids ，删除合并的 mr_iid
					merge_request_iids = target_deploy.merge_request_iids
					merge_request_iids.delete(object.object_attributes.iid)
					target_deploy.update(merge_request_iids: merge_request_iids)

					if object.object_attributes.target.default_branch == 'master'
						# 如果是已合并到 master，则触发主发布处理 CD
						target_deploy.merge
						# target_deploy.main_deploy.process
					end
				else
					print '钉钉一波'
					# 钉钉一波
				end
			end
		end
	end
end