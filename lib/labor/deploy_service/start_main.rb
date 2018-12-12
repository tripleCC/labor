require_relative './base'
require_relative '../external_pod/sorter'
require_relative '../git/string_extension'
require_relative '../remote_file'

module Labor
	module DeployService
		class StartMain < Base 
			def execute
				@deploy = MainDeploy.includes(:pod_deploys).find(deploy.id)
				
				# 分析依赖，获取需要发布的组件
				logger.info("main deploy (id: #{deploy.id}, name: #{deploy.name}): start main deploy")
				deploy.deploy if deploy.can_deploy?
				deploy.pod_deploys.reject(&:success?).each(&:enqueue)
				deploy.process

				# 多线程会出问题
				# async_each(deploy.pod_deploys, &:enqueue)

				# 这里还没合并 MR ，无法 process
				# project hook 监听到 MR 执行成功后，即可 process
				# deploy.process
			end

		end
	end
end