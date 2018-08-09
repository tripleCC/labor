require 'cocoapods-external-pod-sorter'
require_relative '../git/string_extension'
require_relative '../deploy_service'
require_relative '../thread_pool'
require_relative '../logger'
require_relative '../remote_data_source'
require_relative '../remote_file/specification'
require_relative '../utils/pod_item'

module Labor
	class PrepareMainDeployService < DeployService
		include Labor::Logger

		def execute
			# 分析依赖，获取需要发布的组件

			grouped_pods = sort_grouped_pods
			logger.info("create pod deploys for #{deploy.repo_url} : #{grouped_pods}")
			deploy.pod_deploys = create_pod_deploys(grouped_pods)
			prepare_pod_deploys(deploy.pod_deploys)

			# 这里还没合并 MR ，无法 process
			# project hook 监听到 MR 执行成功后，即可 process
			# deploy.process
		end

		# 创建需要发布的组件
		def create_pod_deploys(pods)
			bank = MemberReminder::MemberBank.new
			pod_deploys = pods.flatten.map do |pod|
				deploy_hash = {
					name: pod.name,
					repo_url: pod.repo_url,
					ref: pod.ref
				}
				member = bank.member_of_spec(pod.spec)
				deploy_hash.merge!({
					owner: member.name,
					owner_mobile: member.mobile,
					owner_ding_token: member.team.ding_token
				}) if member 

				pod_deploy = PodDeploy.create(deploy_hash)
				pod_deploy
			end
			pod_deploys
		end

		def prepare_pod_deploys(deploys)
			deploys.map do |pod_deploy|
				thread = Thread.new do 
					pod_deploy.prepare
				end
				thread
			end.each(&:join)
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