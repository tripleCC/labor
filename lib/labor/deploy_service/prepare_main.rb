require_relative './base'
require_relative '../external_pod/sorter'
require_relative '../git/string_extension'
require_relative '../remote_file'

module Labor
	module DeployService
		class PrepareMain < Base 
			def execute
				p deploy.repo_url
				project = gitlab.project(deploy.repo_url)
				deploy.update(project_id: project.id)

				# 分析依赖，获取需要发布的组件
				grouped_pods = sort_grouped_pods
				logger.info("main deploy (id: #{deploy.id}, name: #{deploy.name}): create pod deploys: #{grouped_pods}")

				deploy.pod_deploys = create_pod_deploys(grouped_pods)
				deploy.pod_deploys.each(&:enqueue)
				deploy.deploy
				# 多线程会出问题
				# async_each(deploy.pod_deploys, &:enqueue)

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
						ref: pod.ref,
						version: pod.version,
						external_dependency_names: pod.external_dependency_names
					}
					member = bank.member_of_spec(pod.spec)
					deploy_hash.merge!({
						owner: member.name,
						owner_mobile: member.mobile,
						owner_ding_token: member.team.ding_token
					}) if member 

					pod_deploy = PodDeploy.create!(deploy_hash)
					pod_deploy
				end
				pod_deploys
			end

			def sort_grouped_pods
				# 排序分析未发布的组件
				data_source = ExternalPod::Sorter::DataSource::Remote.new(deploy.project_id, deploy.ref)
				sorter = ExternalPod::Sorter.new(data_source)
				sorter.sort
				sorter.grouped_pods
			end
		end
	end
end