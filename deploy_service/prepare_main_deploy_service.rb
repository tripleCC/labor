require_relative '../git/string_extension'
require_relative '../deploy_service'
require_relative '../thread_pool'
require_relative '../logger'

module Labor
	class PrepareMainDeployService < DeployService
		include Labor::Logger
		using StringExtension

		def execute
			# 向所有组件发起 MR 请求
			deploy.grouped_pods.flatten.map do |pod|
				thread = Thread.new do 
					project_id = project_id_of_pod(pod)
					ref = pod.dependency.external_source[:branch]

					logger.info("prepare for #{pod.name} #{project_id} deploy")
					# 添加 project hook，监听 MR / PL 的执行进度
					add_project_hook(project_id)

					unless ref.is_master?
						owner = pod.spec.member
						
						post_content = "#{pod.name} 组件发版合并，请及时进行 CodeReview 并处理 MergeReqeust."
						assignee_name = owner.name if owner 

						# gitflow 工作流需要合并至 master 和 develop
						post_content << create_merge_request(project_id, ref, 'master', assignee_name)
						unless ref.is_develop? || gitlab.branch(project_id, 'develop').nil?
							post_content << create_merge_request(project_id, ref, 'develop', assignee_name) 
						end

						# 发送组件合并钉钉消息
						# owner.post(post_content) if owner
					end
				end
				thread
			end.each(&:join)

			# 这里还没合并 MR ，无法 process
			# project hook 监听到 MR 执行成功后，即可 process
			# deploy.process
		end

		def project_id_of_pod(pod)
			repo_url = pod.dependency.external_source[:git]
			pod_project = gitlab.project(repo_url)
			pod_project.id
		end

		def create_merge_request(project_id, ref, target, assignee_name)
			title = "merge #{ref} into #{target}".ci_skip
			logger.info("create MR to project #{project_id} with title #{title}")

			mr = gitlab.create_merge_request(project_id, title, assignee_name, {source_branch: ref, target_branch: target})
			"\n#{ref} to #{target}: #{mr.web_url}"
		end

		def add_project_hook(project_id)
			logger.info("add project hook to project #{project_id}")
			gitlab.add_project_hook(project_id, 'http://10.1.130.206:8080/')
		end
	end
end