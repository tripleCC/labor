require 'active_record'
require_relative '../git/gitlab'
require_relative '../remote_file/podfile/template'

module Labor
	class RepoValidator < ActiveModel::Validator
		include Labor::GitLab

		def validate(deploy)
			begin
				project = gitlab.project(deploy.repo_url) if deploy.repo_url
			rescue Labor::Error::NotFound => error
		    deploy.errors[:repo_url] << "Invalid #{deploy.repo_url}, , can't find repo with url #{deploy.repo_url}"
		  end

		  begin 
		  	branch = gitlab.branch(project.id, deploy.ref) if project&.id	  	
		  rescue Gitlab::Error::NotFound => error 
		   	deploy.errors[:ref] << "Invalid #{deploy.ref}, can't find branch #{deploy.ref} of #{deploy.repo_url}"		  	
		  end

		  begin 
		  	podfile = Labor::RemoteFile::Podfile::Template.new(project.id, deploy.ref) if project&.id	  	
		  rescue Gitlab::Error::NotFound => error 
		  	deploy.errors[:base] << "Invalid repo (#{deploy.repo_url}) that being deployed , <PodfileTemplate> file is required on the same path with <Podfile>"
		  end
		rescue SocketError, Net::OpenTimeout => error
		  deploy.errors[:base] << "Invalid deploy with error <#{error}>"	
	  end
	end
end