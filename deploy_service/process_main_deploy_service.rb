require_relative '../deploy_service'

module Labor
	class ProcessMainDeployService < DeployService
		def execute
			# deploy 是在多个 CD 上并行的，需要加锁访问 pod_deploys
			deploy.pods_access_lock.lock
			# 计算已经完成的发布
			done_pod_names = deploy.pod_deploys.select { |deploy| deploy.success? }.map(&:name)
			deploy.pods_access_lock.unlock

			# 计算还未发布的 pod
			left_pods = deploy.grouped_pods.flatten.reject { |pod| done_pod_names.include?(pod.name) }

			# 计算接下来可发布的 pod
			next_pods = left_pods.select do |pod|
				left_pods.find { |left_pod| pod.external_dependency_names.include?(left_pod.name) }.nil?
			end
			
			# 下一阶段的 deploy
			new_pod_deploys = next_pods.map do |pod|
				deploy = PodDeploy.new
				deploy
			end
			# 执行下一阶段的 deploy
			new_pod_deploys.each(&:enqueue)

			deploy.pods_access_lock.lock
			# 添加进工程发布下的组件发布数组
			deploy.pod_deploys << new_pod_deploys
			deploy.pods_access_lock.unlock

			new_pod_deploys.any?
		end
	end
end