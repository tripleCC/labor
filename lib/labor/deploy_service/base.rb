require_relative '../git/gitlab'
require_relative '../logger'
require_relative '../errors'

module Labor
	module DeployService
		class Base
			include GitLab
			include Labor::Logger

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
end