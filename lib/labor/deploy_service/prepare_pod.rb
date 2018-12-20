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
				logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): prepare deploy")
				# 添加 project hook，监听 MR / PL 的执行进度
				add_project_hook(deploy.project_id)

				# 没有 CI/CD 配置文件的情况，直接 skipped
				# 需要用户勾选手动发布成功后，直接将其设置为 manual
				skip_deploy_block = proc do |post_content|
					logger.error("【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】#{post_content}")
					deploy.skip
					post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.can_push_ding?
				end  

				begin 
					ci_yaml_file = Labor::RemoteFile::GitLabCIYaml.new(deploy.project_id, deploy.ref)
					unless ci_yaml_file.has_deploy_jobs?
						skip_deploy_block.call("pod deploy (id: #{deploy.id}, name: #{deploy.name}): 仓库未包含 .gitlab-ci.yaml 文件或 .gitlab-ci.yaml 文件未包含发布操作，无法自动发布。手动发布后，再勾选 <已发布>") 
						return
					end
				rescue Labor::Error::NotFound => error
					skip_deploy_block.call(error.message)
				end

				# master 必须为 default 分支
				master_branch = gitlab.branch(deploy.project_id, 'master')
				unless master_branch.default
					post_content = "【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】master 分支必须为 default 分支"
					logger.error(post_content)
					deploy.drop(post_content)
					post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.can_push_ding?
				end
				
				# 发布分支是 master || 发布分支已经合并到 master ，直接标志为可发布
				ref_branch = gitlab.branch(deploy.project_id, deploy.ref)
				if deploy.ref == 'master' || ref_branch.merged
					update_spec_version(deploy, 'master')
					deploy.ready
				else
					update_spec_version(deploy)
					create_gitflow_merge_requests(ref_branch)
				end
			# 分支找不到, 没有权限的情况下
			rescue Labor::Error::NotFound, 
				Gitlab::Error::Forbidden => error
				logger.error("pod deploy (id: #{deploy.id}, name: #{deploy.name}): fail to prepare pod with error #{error}.")
				deploy.drop(error.message)
				post(deploy.owner_ding_token, error.message, deploy.owner_mobile) if deploy.can_push_ding?
			end

			def update_spec_version(deploy, ref = nil)
				specification = RemoteFile::Specification.new(deploy.project_id, ref || deploy.ref)
				specification.edit_remote_version(deploy.version)
			end

			def create_gitflow_merge_requests(ref_branch)
				post_content = "【#{deploy.main_deploy.name}(id: #{deploy.main_deploy_id})|#{deploy.name}】组件发版合并，请及时进行 CodeReview 保证 CI 通过，并到发布平台标志组件为已审查." 

				# gitflow 工作流需要合并至 master 和 develop
				mr, content = create_merge_request(deploy.project_id, deploy.ref, 'master', deploy.owner)
				deploy.merge_request_iids = deploy.merge_request_iids.uniq
				deploy.merge_request_iids << mr.iid unless deploy.merge_request_iids.include?(mr.iid.to_s)
				post_content << content

				# develop 分支可能没有，这里不抛出错误
				begin 
					unless deploy.ref == 'develop'
						compare_result = gitlab.compare(deploy.project_id, 'develop', deploy.ref)
						# 发布分支领先 develop 的情况下才创建 mr
						unless compare_result.diffs.empty? 
							mr, content = create_merge_request(deploy.project_id, deploy.ref, 'develop', deploy.owner) 
							deploy.merge_request_iids << mr.iid unless deploy.merge_request_iids.include?(mr.iid.to_s)
							post_content << content
						end
					end
				rescue Gitlab::Error::NotFound => error
					logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): can't find develop branch.")
				end
				
				deploy.save
				deploy.pend

				# 发送组件合并钉钉消息
				post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.can_push_ding? && Labor.config.remind_owner_when_merge_request_created
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