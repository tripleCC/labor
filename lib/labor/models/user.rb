require 'active_record'

module Labor
  class User < ActiveRecord::Base
  	has_many :main_deploys, -> { order :id }
  	has_many :pod_deploys, -> { order :id }
  	has_many :operations, -> { order :id }

  	# before_save { |user|  }
	end
end