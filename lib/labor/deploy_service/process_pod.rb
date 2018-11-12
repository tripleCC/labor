require 'member_reminder'
require_relative './base'
require_relative '../config'
require_relative '../utils/retry_rescue'

module Labor
	module DeployService
		# 执行 pod 合并到 master 后的步骤
		# 1、合并到 master 后，创建 tag
		# 2、创建此 tag 的 pipeline
		# 3、监听 pl 状态
		class ProcessPod < Base 
			include MemberReminder::DingTalk
			include Labor::RetryRescue

			def execute
				name = deploy.version

				delete_tag(name) if Labor.config.allow_delete_tag_when_already_existed
				create_tag(name)
				pipeline = create_pipeline(name)
				deploy.update(cd_pipeline_id: pipeline.id)
			rescue Gitlab::Error::BadRequest => error
				drop_deploy(error)
			end

			def drop_deploy(error) 
				logger.error("pod deploy (id: #{deploy.id}, name: #{deploy.name}): failed to process pod deploy with error #{error.message}")
				deploy.drop!(error.message)

				post_content = "发版进程[id: #{deploy.main_deploy.id}, name: #{deploy.main_deploy.name}]:  #{deploy.name} 组件发版失败，错误信息：#{error.message}." 
				post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.owner
			end

			def delete_tag(name)
				# gitlab.tag(project.id, name)
				gitlab.delete_tag(project.id, name)
			rescue Gitlab::Error::NotFound => error
				logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): failed to delete tag(#{name}) with error #{error}")
			end

			def create_tag(name)
				# 注意，tag 重复的话会抛出错误
				logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): create tag #{name}")
				tag = gitlab.create_tag(project.id, name, 'master')
				tag
			end

			def create_pipeline(name)
				# 这里立刻调用 create_pipeline 接口，虽然可以 gitlab 成功创建 pipeline
				# 但是依然会抛出 400 错误，提示 tag 不存在
				# 这里先去查找是否有最新的 pipeline，一定程度上
				# 规避了这个问题
				pipeline = gitlab.newest_active_pipeline(project.id, name)
				# 这里立刻创建 pipeline 的话，可能会出现找不到 tag 错误，所以延迟重试 0.15
				retry_rescue Gitlab::Error::BadRequest do |rest_times|
					logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): create pipeline with rest times #{rest_times}")
					pipeline = gitlab.create_pipeline(project.id, name)	if pipeline.nil?
				end
				logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): run pipeline (#{pipeline.id})")
				pipeline
			end
		end
	end
end