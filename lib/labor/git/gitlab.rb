require 'gitlab'
require_relative './gitlab_proxy'
require_relative '../config'

module Labor
	module GitLab
		def self.gitlab
			@gitlab ||= begin
				client = ::Gitlab.client({ 
					endpoint: Labor.config.gitlab_endpoint, 
					private_token: Labor.config.gitlab_private_token,
					httparty: {timeout: Labor.config.gitlab_http_timeout}
					})
				proxy = GitLabProxy.new(client)
				proxy
			end
		end

		def gitlab
			GitLab.gitlab
		end
	end
end