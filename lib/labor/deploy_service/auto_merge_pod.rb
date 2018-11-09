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
				@deploy = PodDeploy.find(deploy.id)

				if deploy.merge_request_iids.any?
					deploy.merge_request_iids.map do |mr_iid|
						thread = Thread.new do 
							# Fix:
							# SocketError Failed to open TCP connection to git.2dfire-inc.com:80 这里概率出现这个错误
							mr = gitlab.merge_requests(deploy.project_id, mr_iid.to_s).first

							# 已合并，直接走 process 流程
							# 已合并时，prepare 阶段不会提 mr，也就是 merge_request_iids 为空
							# 这里主要考虑了 prepare 阶段创建了 mr ，开发者手动合并的情况
							if mr.state == 'merged'
								deploy.ready
							else
								# accept_merge_request 的 merge_when_pipeline_succeeds 参数需要有活动的 PL 才会生效
								# 这里处理完 PL 之后，才请求自动合并
								pipeline = activate_pipeline(mr)

								# 记录 MR 对应的 PL id ，失败了去 hook event handler 中的 Pipeline 提醒开发者
								deploy.update(mr_pipeline_id: pipeline.id)

								# 已经设置成 pl 成功后合并，则不执行 accept_merge_request
								next if mr.merge_when_pipeline_succeeds

								begin
									logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): accept #{deploy.name}'s MR(#{mr_iid}) when pipeline success")
									# 发起合并请求，必须是 PL 成功后才合并
									gitlab.accept_merge_request(deploy.project_id, mr_iid)
								rescue Gitlab::Error::MethodNotAllowed => error
									# 这里不 drop，继续 pending ，直到负责人来解决

									# TODO: 这里再查一下是否 mr close 了才出现的这个错误，时间差问题
									mr = gitlab.merge_requests(deploy.project_id, mr_iid.to_s).first

									# pipeline 已经成功了，但是合并冲突 && 没有对应 mr，会直接走这里
									if deploy.reviewed?
										post_content = "【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】合并 MR (iid: #{mr_iid}, state: #{mr.state}, 源分支: #{mr.source_branch}, 目标分支: #{mr.target_branch}, 地址: #{mr.web_url}) 失败, 请确认合并是否出现冲突, 原因: #{error}"
										post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.owner
									end

									logger.error("pod deploy (id: #{deploy.id}, name: #{deploy.name}): fail to accept #{deploy.name}'s MR(iid: #{mr_iid}, state: #{mr.state}) with error: #{error}")
								end
							end
						end
						thread
					end.each(&:join)
				else 
					# 如果没有 mr 了，这里假设已经合并成功
					deploy.ready 

					# 执行下一句会死循环
					# deploy.main_deploy.process
				end
			end

			private

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
						logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): create project(#{mr.project_id}) pipeline(#{pipelines.first.id}) for MR(#{mr.iid})")
						active_pipeline = gitlab.create_pipeline(mr.project_id, mr.source_branch)
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