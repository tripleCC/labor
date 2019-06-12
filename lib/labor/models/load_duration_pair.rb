require 'active_record'

module Labor
  class LoadDurationPair < ActiveRecord::Base
  	belongs_to :launch_info
	end
end