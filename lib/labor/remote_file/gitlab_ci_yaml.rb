require 'cocoapods-core'
require_relative './base'

module Labor
	module RemoteFile
		class GitLabCIYaml < Base

			CI_CONFIG_FILE_NAME = '.gitlab-ci.yml'.freeze

			# DEPLOY_JOBS = ['package_framework', 'publish_pod'].freeze
			DEPLOY_JOBS = ['publish_pod', 'publish_code_pod', 'publish_binary_pod'].freeze

			def initialize(project_id, ref = 'master', path = nil)
				path ||= gitlab.file_path(project_id, CI_CONFIG_FILE_NAME, ref, 1)

				super project_id, ref, path
			end

			def has_deploy_jobs?
				(config.keys & DEPLOY_JOBS).any? #== DEPLOY_JOBS			
			end

			def config
				@config ||= begin
					config = YAML.load(file_contents)
					config
				rescue Gitlab::Error::NotFound
					{}
				end
			end
		end
	end
end