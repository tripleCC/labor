require 'active_record'

module Labor
  class LaunchInfo < ActiveRecord::Base
  	# join app_info os_info 导致这里的 order 失效
  	# https://github.com/rails/rails/issues/6769
  	has_many :load_duration_pairs, -> { order :duration }
  	belongs_to :app_info
  	belongs_to :os_info

  	scope :with_app, lambda { |app| joins(:app_info).where(app_infos: app) }
  	scope :with_os, lambda { |os| joins(:os_info).where(os_infos: os) }
	end
end