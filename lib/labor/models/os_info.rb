require 'active_record'

module Labor
  class OsInfo < ActiveRecord::Base
  	has_many :launch_infos
	end
end