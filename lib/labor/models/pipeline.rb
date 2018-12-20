require 'active_record'
require 'will_paginate'
require 'will_paginate/active_record'

module Labor
  class Pipeline < ActiveRecord::Base
  	belongs_to :pod_deploy

  	# before_save { |user|  }
	end
end