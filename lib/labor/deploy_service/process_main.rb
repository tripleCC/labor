require_relative './base'
require_relative '../remote_file'
require_relative '../utils/async'

module Labor
	module DeployService
		# 启动可以执行 CD 的组件发布
		# 1、获取还未发布的组件
		# 2、过滤出可发布的组件
		# 3、执行组件发布
		class ProcessMain < Base
			include Labor::Async

			def execute
				# 从 pod_deploy 调用 main_deploy，其属性 pod_deploys 未更新到最新 state
				# 走到 state_machine after callback，数据库实际已经更新了，这里从数据库再获取一次
				@deploy = MainDeploy.includes(:pod_deploys).find(deploy.id)
				
				deploy.with_lock do 
					logger.info("process main deploy #{deploy.name} #{deploy.id}")

					running_deploys = deploy.pod_deploys.select(&:deploying?)

					# 这里可以检查有 cd_pl 的 deploying 组件，看有没有成功，成功了就标志为 success
					# 以防 webhook 回调丢失后，一直处于 deploying 状态
					running_deploys.select(&:cd_pipeline_id).each do |pod_deploy|
						pipeline = gitlab.pipeline(pod_deploy.project_id, pod_deploy.cd_pipeline_id)
						pod_deploy.success if pipeline&.status == 'success'
					end

					# TODO: 这里可以查看下这在发布中的组件，在有 tag 的前提下是否有对应的 pl，没有的话，创建 pl

					# 计算还未发布的 pod
					left_pod_deploys = deploy.pod_deploys.reject(&:success?)
					left_pod_deploy_names = left_pod_deploys.map(&:name)

					# 启动未分析的发布
					# left_pod_deploys.select(&:created?).each(&:enqueue)


					free_pod_deploys = left_pod_deploys.select do |pod_deploy|
						(pod_deploy.external_dependency_names & left_pod_deploy_names).empty?
					end

					# 计算接下来可发布的 pod
					# 依赖中没有未发布的组件 && 已经合并过 MR  
					next_pod_deploys = free_pod_deploys.select(&:merged?)

					# pending 并且已经 reviewed 组件 的组件，触发 mr 的 pipeline 并 auto merge
					# mr 和发布一样， lint 也需要按照依赖顺序
					# 标志为 reviewed 并且 pending，说明首次 mr 的 ci 失败了，可能依赖了待发布的组件
					# 这里触发 mr ci ，自动合并没有依赖待发布列表中组件的组件
					pending_reviewed_pod_deploys = free_pod_deploys.select do |pod_deploy|
						pod_deploy.pending? && pod_deploy.reviewed
					end

					pending_reviewed_pod_deploys.each(&:auto_merge)
					next_pod_deploys_after_auto_merge = pending_reviewed_pod_deploys.select(&:merged?)
					pending_reviewed_pod_deploys -= next_pod_deploys_after_auto_merge

					# 执行 auto_merge 后，有些组件是 merged, 则将其加入 deploy 数组
					next_pod_deploys += next_pod_deploys_after_auto_merge

					logger.info(
						<<~EOF 
						main deploy (id: #{deploy.id}, name: #{deploy.name})
						---> left pod deploys #{left_pod_deploy_names}
						---> free pod deploys #{free_pod_deploys.map(&:name)}
						---> pending reviewed pod deploys #{pending_reviewed_pod_deploys.map(&:name)}
						---> processing deploys #{running_deploys.map(&:name)}
						---> next process pod deploys #{next_pod_deploys.map(&:name)}
						EOF
					)

					# 执行下一阶段的 deploy
					# next_pod_deploys.each(&:deploy)
					next_pod_deploys.each(&:process)

						# 没有遗留的组件，标志此次工程发布成功
					release_deploy(deploy) if left_pod_deploys.empty?

					left_pod_deploys.empty?
				end
			end

			def release_deploy(deploy) 
				logger.info("main deploy (id: #{deploy.id}, name: #{deploy.name}): update podfile #{deploy.ref}")	
				# 更新 Podfile
				podfile = Labor::RemoteFile::Podfile.new(deploy.project_id, deploy.ref)
				versions = deploy.pod_deploys.map { |pod_deploy| [pod_deploy.name, pod_deploy.version] }.to_h
				podfile.edit_remote(versions)

				logger.info("main deploy (id: #{deploy.id}, name: #{deploy.name}): deploy success with pod_deploy versions #{versions}")	

				deploy.success 
			rescue Labor::Error::NotFound => error 
				# 缺失 PodfileTemplate 
				deploy.drop(error.message)
			end
		end
	end
end