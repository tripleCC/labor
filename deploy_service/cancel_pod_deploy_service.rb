require_relative '../deploy_service'
require_relative '../logger'

module Labor
	class CancelPodDeployService < DeployService
		include Labor::Logger

		def execute
			cancel_pipelines
		end

		def cancel_pipelines 
			[deploy.mr_pipeline_id, deploy.cd_pipeline_id].compact.each do |pipeline_id|
				gitlab.cancel_pipeline(deploy.project_id, pipeline_id)	
			end
		end
	end
end