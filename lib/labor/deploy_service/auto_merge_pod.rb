require 'member_reminder'
require_relative './base'

module Labor
	module DeployService 
		# 自动合并组件 MR 服务
		# 1、判断MR是否已合并
		# 1.1、已合并，直接走 process (开发者在 review 时手动合并了)
		# 1.2、未合并
		# 1.2.1、重启/创建 MR 对应源分支的 PL （合并请求需要活动的 PL，已让 merge_when_pipeline_succeeds 参数有效，否则会直接合并）
		# 1.2.2、发起合并请求，携带 PL 成功后合并参数
		class AutoMergePod < Base 
			include MemberReminder::DingTalk

			def execute
				if deploy.merge_request_iids.any?
					deploy.merge_request_iids.each do |mr_iid|
						# thread = Thread.new do 
							# Fix:
							# SocketError Failed to open TCP connection to git.2dfire-inc.com:80 这里概率出现这个错误
							mr = gitlab.merge_request(deploy.project_id, mr_iid.to_s)

							# 已合并，直接走 process 流程
							# 已合并时，prepare 阶段不会提 mr，也就是 merge_request_iids 为空
							# 这里主要考虑了 prepare 阶段创建了 mr ，开发者手动合并的情况
							if mr.state == 'merged'
								deploy.ready
							else
								# accept_merge_request 的 merge_when_pipeline_succeeds 参数需要有活动的 PL 才会生效
								# 这里处理完 PL 之后，才请求自动合并
								begin
									pipeline = activate_pipeline(mr)

									# 记录 MR 对应的 PL id ，失败了去 hook event handler 中的 Pipeline 提醒开发者
									deploy.update(mr_pipeline_id: pipeline.id)

									# pl 的状态为 success 并且 merge_when_pipeline_succeeds 为 true 时，mr 有概率不会自动合并，需要 accept 或者重新触发一次 pl
									# 这里直接采用 accept 一次，如果自动 merge 了，在 rescue 里面判断，直接 ready
									next if mr.merge_when_pipeline_succeeds && pipeline.status != 'success'

									logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): accept #{deploy.name}'s MR(#{mr_iid}) when pipeline success")
									# 发起合并请求，必须是 PL 成功后才合并
									gitlab.accept_merge_request(deploy.project_id, mr_iid)
								rescue Gitlab::Error::MethodNotAllowed, 
											 Gitlab::Error::BadRequest => error
									# 这里不 drop，继续 pending ，直到负责人来解决
									# New: 直接 drop，算失败

									mr = gitlab.merge_request(deploy.project_id, mr_iid.to_s)

									# 这里有可能是因为 mr 在上次确认～accept之间被 merge 了，如果是的话，直接ready
									if mr.state == 'merged'
										deploy.ready
									else
										post_content = error.message
										if mr.state == 'closed' 
											# 这里 mr closed 后，移除 merge_request_iid，然后 drop
											deploy.update(merge_request_iids: deploy.merge_request_iids.delete(mr.iid.to_s))
											post_content = "【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】MR #{mr.iid} 已被关闭，地址: #{mr.web_url}"
										elsif !mr.merge_when_pipeline_succeeds && mr.merge_status == 'can_be_merged'
											# 有些需要合并的 ref 没有 stages /jobs，会导致 mr 报 400 #35
											gitlab.accept_merge_request(deploy.project_id, mr_iid, {})
										elsif deploy.reviewed?
											# mr.merge_status == 'cannot_be_merged' 
											# pipeline 已经成功了，但是合并冲突 || 没有对应 mr，会直接走这里
											post_content = "【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】合并 MR ( iid: #{mr_iid}, state: #{mr.state}, 源分支: #{mr.source_branch}, 目标分支: #{mr.target_branch}, 地址: #{mr.web_url} ) 失败, 请确认合并是否出现冲突, 原因: #{error}"
										end

										deploy.drop(post_content)
										post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.can_push_ding? 

										logger.error("【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】fail to accept #{deploy.name}'s MR(iid: #{mr_iid}, state: #{mr.state}) with error: #{error}")
									end
								end
							end
						# end
						# thread
					end#.each(&:join)
				else 
					# 如果没有 mr 了，这里假设已经合并成功
					deploy.ready 

					# 执行下一句会死循环
					# deploy.main_deploy.process
				end
			end

			private

			# 这里可能出现 Gitlab::Error::BadRequest
			# 目标无法触发 pl 的情况下
			def activate_pipeline(mr)
				pipelines = pipelines(mr)
				# 没有 active 的 PL ，才做后续操作
				active_pipeline = pipelines.find { |pl| %w[running pending success].include?(pl.status) }
				unless active_pipeline
					# skipped 的 PL 即使 retry 也不会重新启动，需要重新创建
					no_skiped_pipelines = pipelines.reject { |pl| pl.status == 'skipped' }
					if no_skiped_pipelines.any? 
						# 重试非 skipped 的 PL
						retry_pipeline_id = no_skiped_pipelines.first.id
						logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): retry project(#{mr.project_id}) pipeline(#{retry_pipeline_id}) for MR(#{mr.iid})")
						active_pipeline = gitlab.retry_pipeline(mr.project_id, retry_pipeline_id) 
					else
						# 如果没有活动的 PL ，则手动创建一个，这个 PL 会忽略 [ci skip]
						active_pipeline = gitlab.create_pipeline(mr.project_id, mr.source_branch)
						logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): create project(#{mr.project_id}) pipeline(#{active_pipeline.id}) for MR(#{mr.iid})")
					end
				end
				active_pipeline
			end

			def pipelines(mr)
				pipelines = gitlab.pipelines(mr.project_id).select do |pl|
					pl.ref == mr.source_branch &&
					pl.sha == mr.sha
				end
				pipelines
			end
		end
	end
end