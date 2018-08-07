require_relative './git/gitlab'

module Labor
	class DeployService
		include GitLab

		attr_reader :deploy

		def initialize(deploy)
			@deploy = deploy
		end

		def project
			@project ||= begin 
				project = gitlab.project(@deploy.repo_url)
				project
			end
		end

		def execute
			
		end
	end
end