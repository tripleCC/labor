require_relative './base'
require_relative '../remote_file'

module Labor
	module DeployService
		# 启动可以执行 CD 的组件发布
		# 1、获取还未发布的组件
		# 2、过滤出可发布的组件
		# 3、执行组件发布
		class ProcessMain < Base
			def execute
				# 计算还未发布的 pod
				left_pod_deploys = deploy.pod_deploys.reject { |deploy| deploy.success? }
				left_pod_deploy_names = left_pod_deploys.map(&:name)

				running_deploy_names = deploy.pod_deploys.select { |deploy| deploy.deploying? }.map(&:name)

				# 计算接下来可发布的 pod
				next_pod_deploys = left_pod_deploys.select do |pod_deploy|
					# 依赖中没有未发布的组件 && 已经合并过 MR 
					(pod_deploy.external_dependency_names & left_pod_deploy_names).empty? &&
					pod_deploy.merged? 
				end

				logger.info("main deploy (id: #{deploy.id}, name: #{deploy.name}): left pod deploys #{left_pod_deploy_names}, running deploys #{running_deploy_names}, start next pod deploys #{next_pod_deploys.map(&:name)}")
				
				# 执行下一阶段的 deploy
				next_pod_deploys.each(&:deploy)

				# 没有遗留的组件，标志此次工程发布成功
				if left_pod_deploys.empty?
					logger.info("main deploy (id: #{deploy.id}, name: #{deploy.name}): update podfile #{deploy.ref}")	
					# 更新 Podfile
					podfile = Labor::RemoteFile::Podfile.new(deploy.project_id, deploy.ref)
					podfile.edit_remote

					logger.info("main deploy (id: #{deploy.id}, name: #{deploy.name}): deploy success")	
					deploy.success 
				end

				left_pod_deploys.empty?
			end
		end
	end
end