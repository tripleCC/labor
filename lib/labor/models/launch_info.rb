require 'active_record'

module Labor
  class LaunchInfo < ActiveRecord::Base
  	# join app_info os_info 导致这里的 order 失效
  	# https://github.com/rails/rails/issues/6769
  	has_many :load_duration_pairs, -> { order :duration }
  	belongs_to :app_info
  	belongs_to :os_info
  	belongs_to :device

  	scope :with_app, lambda { |app| app.any? ? joins(:app_info).where(app_infos: app) : all }
  	scope :with_os, lambda { |os| os.any? ? joins(:os_info).where(os_infos: os) : all }
  	scope :with_device, lambda { |dev| dev.any? ? joins(:device).where(devices: dev) : all }

	end
end