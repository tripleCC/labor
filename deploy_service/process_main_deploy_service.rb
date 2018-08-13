require_relative '../deploy_service'
require_relative '../logger'

module Labor
	# 启动可以执行 CD 的组件发布
	# 1、获取还未发布的组件
	# 2、过滤出可发布的组件
	# 3、执行组件发布
	class ProcessMainDeployService < DeployService
		include Labor::Logger

		def execute
			# 计算还未发布的 pod
			left_pod_deploys = deploy.pod_deploys.reject { |deploy| deploy.success? }
			left_pod_deploy_names = left_pod_deploys.map(&:name)

			# 计算接下来可发布的 pod
			next_pod_deploys = left_pod_deploys.select do |pod_deploy|
				# 依赖中没有未发布的组件 && 已经合并过 MR 
				(pod_deploy.external_dependency_names & left_pod_deploy_names).empty? &&
				pod_deploy.merged?
			end

			logger.info("main deploy (id: #{deploy.id}, name: #{deploy.name}): left pod deploys #{left_pod_deploy_names}, start next pod deploys #{next_pod_deploys.map(&:name)}")
			
			# 执行下一阶段的 deploy
			next_pod_deploys.each(&:enqueue)

			next_pod_deploys.any?
		end
	end
end