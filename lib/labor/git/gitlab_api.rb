class Gitlab::Client
  # Defines methods related to merge requests.
  # @see https://docs.gitlab.com/ce/api/merge_requests.html
  module MergeRequests
  	# Only for admins and project owners
  	def delete_merge_request(project, merge_request_iid)
      delete("/projects/#{url_encode project}/merge_requests/#{merge_request_iid}")
    end
  end

  # module Pipelines
  # 	old_create_pipeline = instance_method(:create_pipeline)
  # 	define_method(:create_pipeline) do |project, ref|
  # 		old_create_pipeline.bind(self).call(project, url_encode(ref))
  # 	end
  # end
end