require_relative '../git/string_extension'
require_relative '../deploy_service'

module Labor
	class PreparePodDeployService < DeployService
		def execute
			# 获取需要合并的分支
			ref = pod.dependency.external_source[:branch]
			if !ref.is_master?
				gitlab.add_project_hook(project.id, 'http://10.1.130.206:8080/')

				# 获取组件负责人
				owner = pod.spec.member
				if owner 
					# 发送组件合并钉钉消息
					owner.post("#{pod.name} 组件发版合并，请及时进行 CodeReview 并处理 MergeReqeust.")
					assignee_name = owner.name
				end
				title = "merge #{ref} into master".ci_skip
				# 触发 MR ，合并至 master
				gitlab.create_merge_request(project.id, title, assignee_name, {source_branch: ref, target_branch: 'master'})

				if ref.is_develop?
					# 触发 MR ，合并至 develop
					# 这一步是为了迎合 gitflow 工作流
					title = "merge #{re} into develop".ci_skip
					gitlab.create_merge_request(project.id, title, assignee_name, {source_branch: ref, target_branch: 'develop'})					
				end
			else 
				# 如果是master分支，直接处理 deploy
				deploy.process
			end
		end
	end
end