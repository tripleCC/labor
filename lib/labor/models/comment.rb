require 'active_record'

module Labor
  class Comment < ActiveRecord::Base
  	belongs_to :user
  	belongs_to :leak_info

  	before_save :user_name_pre_save_method

  	def user_name_pre_save_method
  		self.user_name = self.user.nickname
  	end
	end
end