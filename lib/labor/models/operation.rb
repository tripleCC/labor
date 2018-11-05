require 'active_record'
require 'will_paginate'
require 'will_paginate/active_record'

module Labor
  class Operation < ActiveRecord::Base
  	belongs_to :user
  	belongs_to :pod_deploy
  	belongs_to :main_deploy

  	self.per_page = 30
  	# before_save { |user|  }
	end
end