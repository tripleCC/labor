require 'active_record'

module Labor
  class User < ActiveRecord::Base
  	has_many :main_deploys, -> { order :id }
	end
end