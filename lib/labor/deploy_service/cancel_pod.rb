require_relative './base'

module Labor
	module DeployService
		class CancelPod < Base 

			def execute
				cancel_pipelines
			end

			def cancel_pipelines 
				[deploy.mr_pipeline_id, deploy.cd_pipeline_id].compact.each do |pipeline_id|
					gitlab.cancel_pipeline(deploy.project_id, pipeline_id)	
				end

				deploy.merge_request_iids.compact.each do |merge_request_iid|
					gitlab.update_merge_request(deploy.project_id, merge_request_iid, { state_event: 'close' })
				end
				deploy.merge_request_iids.clear
				deploy.save
			end
		end
	end
end