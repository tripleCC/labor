require 'active_record'
require_relative '../git/gitlab'

module Labor
  class Project < ActiveRecord::Base
  	has_many :pod_deploys, -> { distinct }
  	has_many :main_deploys, -> { distinct }

  	# before_save { |user|  }

  	class << self 
	  	def find_or_create_by_repo_url(repo_url)
	  		project = find_by_repo_url(repo_url)
	      unless project 
	        gitlab_project = Labor::GitLab.gitlab.project(repo_url) 

	        project = find_or_create_by(id: gitlab_project.id).tap do |pr|
	        	params = column_names.reduce({}) do |params, key| 
			  			next params unless gitlab_project.respond_to?(key)
			  			params[key] = gitlab_project.send(key)
			  		 	params 
			  		end 
			  		pr.update_attributes(params)
	        end
	      end
	      project
	  	end

  		def find_by_repo_url(repo_url) 
	  		find_by("ssh_url_to_repo = ? OR http_url_to_repo = ?", repo_url, repo_url)
	  	rescue ActiveRecord::RecordNotFound => error
	  		nil
	  	end
  	end
	end
end