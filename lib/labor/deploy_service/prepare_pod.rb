require 'member_reminder'
require_relative './base'
require_relative '../config'
require_relative '../git/string_extension'
require_relative '../remote_file'

module Labor
	module DeployService
		class PreparePod < Base 
			include MemberReminder::DingTalk
			using StringExtension
			
			def execute
				project = gitlab.project(deploy.repo_url)
				deploy.update(project_id: project.id)
				
				logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): prepare deploy")
				# 添加 project hook，监听 MR / PL 的执行进度
				add_project_hook(deploy.project_id)

				# 没有 CI/CD 配置文件的情况，直接 skipped
				# 需要用户勾选手动发布成功后，直接将其设置为 manual
				ci_yaml_file = Labor::RemoteFile::GitLabCIYaml.new(deploy.project_id, deploy.ref)
				unless ci_yaml_file.has_deploy_jobs?
					deploy.skip
					post_content = "pod deploy (id: #{deploy.id}, name: #{deploy.name}): .gitlab-ci.yaml 文件未包含发布操作，无法自动发布。手动发布后，再勾选 <已手动发布>"
					post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.owner
					return
				end

				# 发布分支是 master || 发布分支已经合并到 master ，直接标志为可发布
				if deploy.ref == 'master' || gitlab.branch(deploy.project_id, deploy.ref).merged
					update_spec_version(deploy, 'master')
					deploy.ready
				else
					update_spec_version(deploy)
					create_gitflow_merge_requests
				end
			end

			def update_spec_version(deploy, ref = nil)
				specification = RemoteFile::Specification.new(deploy.project_id, ref || deploy.ref)
				specification.edit_remote_version(deploy.version)
			end

			def create_gitflow_merge_requests
				post_content = "发版进程[id: #{deploy.main_deploy.id}, name: #{deploy.main_deploy.name}]:#{deploy.name} 组件发版合并，请及时进行 CodeReview 并处理 MergeReqeust." 

				# gitflow 工作流需要合并至 master 和 develop
				mr, content = create_merge_request(deploy.project_id, deploy.ref, 'master', deploy.owner)
				deploy.merge_request_iids << mr.iid
				post_content << content

				# develop 分支可能没有，这里不抛出错误
				begin 
					unless deploy.ref == 'develop' || gitlab.branch(deploy.project_id, 'develop').nil?
						mr, content = create_merge_request(deploy.project_id, deploy.ref, 'develop', deploy.owner) 
						deploy.merge_request_iids << mr.iid
						post_content << content
					end
				rescue Gitlab::Error::NotFound => error
					logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): can't find develop branch.")
				end
				
				deploy.save
				deploy.pend

				# 发送组件合并钉钉消息
				post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.owner
			end

			def create_merge_request(project_id, ref, target, assignee_name)
				title = "merge #{ref} into #{target}".ci_skip
				logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): create MR to project #{project_id} with assignee #{assignee_name} and title #{title}")

				mr = gitlab.create_merge_request(project_id, title, assignee_name, {source_branch: ref, target_branch: target})
				[mr, "\n#{ref} to #{target}: #{mr.web_url}"]
			end

			def add_project_hook(project_id)
				logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): add project hook to project #{project_id}")
				gitlab.add_project_hook(project_id, Labor.config.webhook_url)
			end
		end
	end
end