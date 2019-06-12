require 'active_record'

module Labor
  class LaunchInfo < ActiveRecord::Base
  	has_many :load_duration_pairs, -> { order :duration }
  	belongs_to :application
  	belongs_to :operation_system
	end
end