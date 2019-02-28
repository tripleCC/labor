require 'active_record'
require 'will_paginate'
require 'will_paginate/active_record'

module Labor
  class Tag < ActiveRecord::Base
  	# belongs_to :project
  	belongs_to :pod_deploy

  	# before_save { |user|  }
  	class << self 
  		def params_of_gitlab_tag(gitlab_tag)
  			params = (column_names - ['sha', 'id']).reduce({}) do |params, key| 
	  			next params unless gitlab_tag.respond_to?(key)
	  			params[key] = gitlab_tag.send(key)
	  		 	params 
	  		end 
  			params['sha'] = gitlab_tag.commit.id 
  			params
  		end
  	end
	end
end