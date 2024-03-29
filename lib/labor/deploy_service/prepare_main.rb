require_relative './base'
require_relative '../external_pod/sorter'
require_relative '../git/string_extension'
require_relative '../remote_file'
require_relative '../models/user'
require_relative '../models/project'
require_relative '../config'

module Labor
	module DeployService
		class PrepareMain < Base 
			def execute
				unless deploy.project
					project = Project.find_or_create_by_repo_url(deploy.repo_url)
					project.main_deploys << deploy 
				end

				# 分析依赖，获取需要发布的组件
				grouped_pods = sort_grouped_pods
				logger.info("main deploy (id: #{deploy.id}, name: #{deploy.name}): prepare main deploy, create pod deploys: #{grouped_pods}")

				deploy.pod_deploys = create_pod_deploys(grouped_pods)
				deploy.save!
				deploy.wait

				# 没有可发布组件直接标志成功
				deploy.success unless deploy.pod_deploys.any?
			end

			# 创建需要发布的组件
			def create_pod_deploys(pods)
				bank = MemberReminder::MemberBank.new
				pod_deploys = pods.flatten.map do |pod|
					deploy_hash = {
						name: pod.name,
						repo_url: pod.repo_url,
						ref: pod.ref,
						version: pod.refer_version,
						external_dependency_names: pod.external_dependency_names
					}
					member = bank.member_of_spec(pod.spec)

					if member 
						deploy_hash.merge!({
							owner: member.name,
							owner_mobile: member.mobile,
							owner_ding_token: member.team&.ding_token
						})

						if member.name
							user = User.find_or_create_by({
								nickname: member.name, 
								phone_number: member.mobile
							}) 
							deploy_hash.merge!({
								user: user
							})
						end
					end

					deploy_hash.merge!({
						reviewed: true 
					}) if Labor.config.reviewed_merge_request_when_created

					project = Project.find_or_create_by_repo_url(pod.repo_url)
					pod_deploy = project.pod_deploys.create!(deploy_hash)
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