require 'active_record'

module Labor
  class Application < ActiveRecord::Base
  	has_many :launch_infos
	end
end