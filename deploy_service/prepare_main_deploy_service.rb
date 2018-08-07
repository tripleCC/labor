require_relative '../git/string_extension'
require_relative '../deploy_service'
require_relative '../thread_pool'
require_relative '../logger'
require_relative '../remote_file/specification'

module Labor
	class PrepareMainDeployService < DeployService
		include Labor::Logger

		def execute
			# 创建需要发布的组件
			deploy.grouped_pods.flatten.map do |pod|
				thread = Thread.new do 
					pod_deploy = PodDeploy.new
					pod_deploy.pod = pod
					pod_deploy.prepare

					# TODO
					# 这里要处理锁
					deploy.pod_deploys << pod_deploy
					# 保存到数据库
				end
				thread
			end.each(&:join)

			# 这里还没合并 MR ，无法 process
			# project hook 监听到 MR 执行成功后，即可 process
			# deploy.process
		end
	end
end