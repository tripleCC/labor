require 'active_record'

module Labor
  class OperationSystem < ActiveRecord::Base
  	has_many :launch_infos
	end
end