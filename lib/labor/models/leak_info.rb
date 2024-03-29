require 'active_record'

module Labor
  class LeakInfo < ActiveRecord::Base
  	belongs_to :app_info
  	belongs_to :user
  	has_many :comments, -> { order :created_at }

  	self.per_page = 15

  	scope :with_app, lambda { |app| app.any? ? joins(:app_info).where(app_infos: app) : all }
  	scope :with_cycles, lambda { where.not(cycles: [nil, '']) }
	end
end