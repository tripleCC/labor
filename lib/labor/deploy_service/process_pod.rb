require 'member_reminder'
require_relative './base'
require_relative '../config'

module Labor
	module DeployService
		# 执行 pod 合并到 master 后的步骤
		# 1、合并到 master 后，创建 tag
		# 2、创建此 tag 的 pipeline
		# 3、监听 pl 状态
		class ProcessPod < Base 
			include MemberReminder::DingTalk

			def execute
				name = deploy.version

				delete_tag(name) if can_delete_tag?(name)
				create_tag(name)
			rescue Gitlab::Error::BadRequest => error
				drop_deploy(error)
			end

			def include_tag?(name)
				deploy.tags.map(&:name).include?(name)
			end

			def can_delete_tag?(name)
				Labor.config.allow_delete_tag_when_already_existed || include_tag?(name)
			end

			def drop_deploy(error) 
				logger.error("pod deploy (id: #{deploy.id}, name: #{deploy.name}): failed to process pod deploy with error #{error.message}")
				deploy.drop!(error.message)

				post_content = "发版进程[id: #{deploy.main_deploy.id}, name: #{deploy.main_deploy.name}]:  #{deploy.name} 组件发版失败，错误信息：#{error.message}." 
				post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.can_push_ding?
			end

			def delete_tag(name)
				# gitlab.tag(deploy.project_id, name)
				gitlab.delete_tag(deploy.project_id, name)
				deleted_tags = deploy.tags.where(name: name)
				deploy.tags.delete(deleted_tags) unless deleted_tags.empty?
			rescue Gitlab::Error::NotFound => error
				logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): failed to delete tag(#{name}) with error #{error}")
			end

			def create_tag(name)
				# 注意，tag 重复的话会抛出错误
				logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): create tag #{name}")
				gitlab_tag = gitlab.create_tag(deploy.project_id, name, 'master')
				create_params = Tag.params_of_gitlab_tag(gitlab_tag)
				tag = deploy.tags.create_with(create_params).find_or_create_by(name: gitlab_tag.name)
				tag
			end
		end
	end
end