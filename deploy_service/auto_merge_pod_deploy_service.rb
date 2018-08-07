
require_relative '../deploy_service'
require_relative '../logger'

module Labor
	# 自动合并组件 MR 服务
	# 1、判断MR是否已合并
	# 1.1、已合并，直接走 process
	# 1.2、未合并
	# 1.2.1、重启/创建 MR 对应源分支的 PL （合并请求需要活动的 PL，已让 merge_when_pipeline_succeeds 参数有效，否则会直接合并）
	# 1.2.2、发起合并请求，携带 PL 成功后合并参数
	class AutoMergePodDeployService < DeployService
		include Labor::Logger

		def execute
			pod_project = gitlab.project(deploy.repo_url)
			deploy.merge_requests.map do |mr_iid|
				thread = Thread.new do 
					mr = gitlab.merge_requests(pod_project.id, mr_iid.to_s).first
					# 已合并，直接走 process 流程
					if mr.state == 'merged'
						deploy.process
					else
						# accept_merge_request 的 merge_when_pipeline_succeeds 参数需要有活动的 PL 才会生效
						# 这里处理完 PL 之后，才请求自动合并
						pipeline = activate_pipeline(mr)

						begin
							logger.info("accept #{pod_project.name}'s MR(#{mr_iid})")
							# 发起合并请求，必须是 PL 成功后才合并
							gitlab.accept_merge_request(pod_project.id, mr_iid)
						rescue Gitlab::Error::MethodNotAllowed => error
							logger.error("fail to accept #{pod_project.name}'s MR(#{mr_iid}) with error: #{error}")
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
					logger.info("retry project(#{mr.project_id}) pipeline(#{retry_pipeline_id}) for MR(#{mr.iid})")
					gitlab.retry_pipeline(mr.project_id, retry_pipeline_id) 
				else
					# 如果没有活动的 PL ，则手动创建一个，这个 PL 会忽略 [ci skip]
					logger.info("create project(#{mr.project_id}) pipeline(#{pipelines.first.id}) for MR(#{mr.iid})")
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