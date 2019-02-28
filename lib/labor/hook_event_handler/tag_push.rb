require_relative './base'
require_relative '../models/tag'
require_relative '../utils/retry_rescue'

module Labor
	module HookEventHandler
		class TagPush < Base 
			include Labor::RetryRescue

			def handle 
				logger.info("receive project(#{object.project.name}) tag push, ref #{object.ref}, checkout_sha #{object.checkout_sha}")

				# 删除不管
				return unless object.checkout_sha

				name = object.ref.split('/').last
				pod_deploys = PodDeploy.joins(:tags).where(
					status: :deploying, 
					project_id: object.project.id, 
					tags: { sha: object.checkout_sha, name: name }
					)
				# tags = Tag.where(
				# 	sha: object.checkout_sha, 
				# 	name: name, 
				# 	pod_deploy: PodDeploy.where(status: :deploying, project_id: object.project.id),
				# 	).includes(:pod_deploy)
				return if pod_deploys.empty?

				logger.info("handle project(#{object.project.name}) tag push, ref #{object.ref}, checkout_sha #{object.checkout_sha}")

				pod_deploys.each do |deploy|
					begin 
						pipeline = create_pipeline(deploy, name)
						deploy.update(cd_pipeline_id: pipeline.id)
					rescue Gitlab::Error::BadRequest => error
						drop_deploy(deploy, error)
					end
				end
			end

			def drop_deploy(deploy, error) 
				logger.error("pod deploy (id: #{deploy.id}, name: #{deploy.name}): failed to process pod deploy with error #{error.message}")
				deploy.drop!(error.message)

				post_content = "发版进程[id: #{deploy.main_deploy.id}, name: #{deploy.main_deploy.name}]:  #{deploy.name} 组件发版失败，错误信息：#{error.message}." 
				post(deploy.owner_ding_token, post_content, deploy.owner_mobile) if deploy.can_push_ding?
			end

			def create_pipeline(deploy, name)
				# 这里立刻调用 create_pipeline 接口，虽然可以 gitlab 成功创建 pipeline
				# 但是依然会抛出 400 错误，提示 tag 不存在
				# 这里先去查找是否有最新的 pipeline，一定程度上
				# 规避了这个问题
				pipeline = gitlab.newest_active_pipeline(deploy.project_id, name)
				# 这里立刻创建 pipeline 的话，可能会出现找不到 tag 错误，所以延迟重试 0.15
				unless pipeline
					retry_rescue Gitlab::Error::BadRequest, 5, 0.5 do |rest_times|
						logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): create pipeline with rest times #{rest_times}")
						pipeline = gitlab.create_pipeline(deploy.project_id, name)	
					end
					logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): run pipeline (#{pipeline.id})")
				else
					logger.info("pod deploy (id: #{deploy.id}, name: #{deploy.name}): newest active pipeline (#{pipeline.id})")
				end

				pipeline
			end
		end
	end
end
