require 'active_record'

module Labor
  class LaunchInfo < ActiveRecord::Base
  	has_many :load_duration_pairs, -> { order :duration }
  	belongs_to :app_info
  	belongs_to :os_info

  	scope :with_app, lambda { |app| joins(:app_info).where(app_infos: app) }
  	scope :with_os, lambda { |os| joins(:os_info).where(os_infos: os) }
	end
end