require_relative '../git/string_extension'
require_relative '../deploy_service'

module Labor
	class PreparePodDeployService < DeployService
		include Labor::Logger
		using StringExtension

		def execute
			pod = deploy.pod
			project_id = project_id_of_pod(pod)
			ref = pod.dependency.external_source[:branch]

			logger.info("prepare for #{pod.name} #{project_id} deploy")
			# 添加 project hook，监听 MR / PL 的执行进度
			add_project_hook(project_id)

			unless ref.is_master?
				update_spec_version(project_id, ref) if ref.has_version?

				owner = pod.spec.member
				post_content = "#{pod.name} 组件发版合并，请及时进行 CodeReview 并处理 MergeReqeust."
				assignee_name = owner.name if owner 

				# gitflow 工作流需要合并至 master 和 develop
				mr, content = create_merge_request(project_id, ref, 'master', assignee_name)
				deploy.merge_requests << mr.iid
				post_content << content

				unless ref.is_develop? || gitlab.branch(project_id, 'develop').nil?
					mr, content = create_merge_request(project_id, ref, 'develop', assignee_name) 
					deploy.merge_requests << mr.iid
					post_content << content
				end

				# 发送组件合并钉钉消息
				# owner.post(post_content) if owner
			end
		end

		def project_id_of_pod(pod)
			repo_url = pod.dependency.external_source[:git]
			pod_project = gitlab.project(repo_url)
			pod_project.id
		end

		def update_spec_version(project_id, ref)
			specification = RemoteFile::Specification.new(project_id, ref)
			specification.modify_version(ref.version)
		end

		def create_merge_request(project_id, ref, target, assignee_name)
			title = "merge #{ref} into #{target}".ci_skip
			logger.info("create MR to project #{project_id} with assignee #{assignee_name} and title #{title}")

			mr = gitlab.create_merge_request(project_id, title, assignee_name, {source_branch: ref, target_branch: target})
			[mr, "\n#{ref} to #{target}: #{mr.web_url}"]
		end

		def add_project_hook(project_id)
			logger.info("add project hook to project #{project_id}")
			gitlab.add_project_hook(project_id, 'http://10.1.130.206:8080/')
		end
	end
end