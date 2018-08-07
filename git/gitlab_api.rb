class Gitlab::Client
  # Defines methods related to merge requests.
  # @see https://docs.gitlab.com/ce/api/merge_requests.html
  module MergeRequests
  	# Only for admins and project owners
  	def delete_merge_request(project, merge_request_iid)
      delete("/projects/#{url_encode project}/merge_requests/#{merge_request_iid}")
    end
  end
end