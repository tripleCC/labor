require 'active_record'
require_relative '../git/gitlab'

module Labor
	class RepoValidator < ActiveModel::Validator
		include Labor::GitLab

		def validate(deploy)
			project = gitlab.project(deploy.repo_url) 
		rescue SocketError, Net::OpenTimeout, Labor::Error::NotFound => error
	    deploy.errors[:repo_url] << "Invalid #{deploy.repo_url} with error #{error}"
	  end
	end
end