require_relative '../deploy_service'

module Labor
	# 执行 pod 合并到 master 后的步骤
	# 1、合并到 master 后，创建 tag
	# 2、创建此 tag 的 pipeline
	# 3、监听 pl 状态
	class ProcessPodDeployService < DeployService
		def execute
			name = deploy.version
			create_tag(name)
			create_pipeline(name)
		rescue Gitlab::Error::BadRequest => error
			deploy.drop(error.message)
		end

		def create_tag(name)
			# 注意，tag 重复的话会抛出错误
			gitlab.create_tag(project.id, name, 'master')
		end

		def create_pipeline(name)
			# 这里立刻调用 create_pipeline 接口，虽然可以 gitlab 成功创建 pipeline
			# 但是依然会抛出 400 错误，提示 tag 不存在
			# 这里先去查找是否有最新的 pipeline，一定程度上
			# 规避了这个问题
			pipeline = gitlab.newest_active_pipeline(project_id, name)
			pipeline = gitlab.create_pipeline(project.id, name)	if pipeline.nil?
			deploy.update(pipeline_id: pipeline.id)
		end
	end
end