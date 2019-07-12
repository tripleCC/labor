require 'active_record'

module Labor
  class AppInfo < ActiveRecord::Base
  	has_many :launch_infos
  	has_many :leak_infos
	end
end