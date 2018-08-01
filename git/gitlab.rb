require 'gitlab'
require_relative './gitlab_proxy'

module Labor
	module GitLab
		def self.gitlab
			@gitlab ||= begin
				client = ::Gitlab.client({ endpoint: 'http://git.2dfire-inc.com/api/v4', private_token: 'Se79zS8rgUupDZv6JN8G' })
				proxy = GitLabProxy.new(client)
				proxy
			end
		end

		def gitlab
			GitLab.gitlab
		end
	end
end