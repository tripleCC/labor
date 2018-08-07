require 'cocoapods-external-pod-sorter'
require 'member_reminder'
require_relative '../deploy_service'
require_relative '../remote_data_source'

module Labor
	class CreateMainDeployService < DeployService
		include Labor::Logger

		def execute
			# 分析依赖，获取需要发布的组件
			deploy.grouped_pods = sort_grouped_pods

			logger.info("create pod deploys for #{deploy.repo_url} : #{deploy.grouped_pods}")

			# 开始处理主发布
			deploy.prepare
		end

		def sort_grouped_pods
			# 排序分析未发布的组件
			data_source = RemoteDataSource.new(project.id, deploy.ref)
			sorter = ExternalPodSorter.new(data_source)
			sorter.sort
			sorter.grouped_pods
		end
	end
end