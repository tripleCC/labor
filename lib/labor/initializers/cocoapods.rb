require_relative '../logger'
require_relative '../config'
require_relative '../external_pod/sorter'
require_relative '../git/gitlab_proxy'
require_relative '../errors'

module Labor
  module Initializer
  	module Cocoapods
  		extend Labor::GitLab

  		def self.config
  			Labor.config
  		end

  		def self.private_source_url
  			config.cocoapods_private_source_url
  		end

  		def self.create_private_source
  			manager = Pod::Config.instance.sources_manager

  			unless manager.all.map(&:url).include?(private_source_url)
					puts "Start adding cocoapods private source with #{private_source_url}"
	  			manager.find_or_create_source_with_url(private_source_url)
	  			puts "Finish adding cocoapods private source with #{private_source_url}"
	  		end
  		end

  		def self.add_webhook
  			project = gitlab.project(private_source_url)

  			raise Labor::Error::Base, "Invalid cocoapods private source url #{private_source_url} which is necessary for the service" if project.nil?

  			gitlab.add_project_hook(project.id, config.cocoapods_webhook_url, push_events: true)
  		end

  		create_private_source
  		Thread.new do 
	  		add_webhook
	  	end
  	end
  end
end