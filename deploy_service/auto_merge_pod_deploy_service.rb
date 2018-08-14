
require_relative '../deploy_service'
require_relative '../logger'

module Labor
	# 自动合并组件 MR 服务
	# 1、判断MR是否已合并
	# 1.1、已合并，直接走 process (开发者在 review 时手动合并了)
	# 1.2、未合并
	# 1.2.1、重启/创建 MR 对应源分支的 PL （合并请求需要活动的 PL，已让 merge_when_pipeline_succeeds 参数有效，否则会直接合并）
	# 1.2.2、发起合并请求，携带 PL 成功后合并参数
	class AutoMergePodDeployService < DeployService
		include Labor::Logger

		def execute
			# TODO 
			# 这里需要处理下 ref 是 master 分支， merge_request_iids 为空的情况
			# 直接设置 merge 给 main_deploy process ？

			deploy.merge_request_iids.map do |mr_iid|
				thread = Thread.new do 
					mr = gitlab.merge_requests(deploy.project_id, mr_iid.to_s).first
					# 已合并，直接走 process 流程
					if mr.state == 'merged'
						deploy.main_deploy.process
					else
						# accept_merge_request 的 merge_when_pipeline_succeeds 参数需要有活动的 PL 才会生效
						# 这里处理完 PL 之后，才请求自动合并
						pipeline = activate_pipeline(mr)

						# 记录 MR 对应的 PL id ，失败了去 hook event handler 中的 Pipeline 提醒开发者
						deploy.update(mr_pipeline_id: pipeline.id)

						begin
							logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): accept #{deploy.name}'s MR(#{mr_iid})")
							# 发起合并请求，必须是 PL 成功后才合并
							gitlab.accept_merge_request(deploy.project_id, mr_iid)
						rescue Gitlab::Error::MethodNotAllowed => error
							logger.error("pod deploy (id: #{deploy.id}, name: #{deploy.name}): fail to accept #{deploy.name}'s MR(#{mr_iid}) with error: #{error}")
						end
					end
				end
				thread
			end.each(&:join)
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
					gitlab.retry_pipeline(mr.project_id, retry_pipeline_id) 
				else
					# 如果没有活动的 PL ，则手动创建一个，这个 PL 会忽略 [ci skip]
					logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): create project(#{mr.project_id}) pipeline(#{pipelines.first.id}) for MR(#{mr.iid})")
					gitlab.create_pipeline(mr.project_id, mr.source_branch)
				end
			end
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