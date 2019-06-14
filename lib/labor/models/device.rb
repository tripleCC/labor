require 'active_record'

module Labor
  class Device < ActiveRecord::Base
  	has_many :launch_infos
  	before_save :simple_name_pre_save_method

  	def simple_name_pre_save_method
  		self.simple_name = 
	  		case self.name
	  		when "iPod5,1" 																	then "iPod Touch 5"
				when "iPod7,1" 																	then "iPod Touch 6"
				when "iPhone3,1", "iPhone3,2", "iPhone3,3" 			then "iPhone 4"
	      when "iPhone4,1"                               	then "iPhone 4s"
	      when "iPhone5,1", "iPhone5,2"                  	then "iPhone 5"
	      when "iPhone5,3", "iPhone5,4"                   then "iPhone 5c"
	      when "iPhone6,1", "iPhone6,2"                   then "iPhone 5s"
	      when "iPhone7,2"                                then "iPhone 6"
	      when "iPhone7,1"                                then "iPhone 6 Plus"
	      when "iPhone8,1"                                then "iPhone 6s"
	      when "iPhone8,2"                                then "iPhone 6s Plus"
	      when "iPhone9,1", "iPhone9,3"                   then "iPhone 7"
	      when "iPhone9,2", "iPhone9,4"                   then "iPhone 7 Plus"
	      when "iPhone8,4"                                then "iPhone SE"
	      when "iPhone10,1", "iPhone10,4"                 then "iPhone 8"
	      when "iPhone10,2", "iPhone10,5"                 then "iPhone 8 Plus"
	      when "iPhone10,3", "iPhone10,6"                 then "iPhone X"
	      when "iPhone11,2"                               then "iPhone XS"
	      when "iPhone11,4", "iPhone11,6"                 then "iPhone XS Max"
	      when "iPhone11,8"                               then "iPhone XR"
	      when "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4" then "iPad 2"
	      when "iPad3,1", "iPad3,2", "iPad3,3"            then "iPad 3"
	      when "iPad3,4", "iPad3,5", "iPad3,6"            then "iPad 4"
	      when "iPad4,1", "iPad4,2", "iPad4,3"            then "iPad Air"
	      when "iPad5,3", "iPad5,4"                       then "iPad Air 2"
	      when "iPad6,11", "iPad6,12"                     then "iPad 5"
	      when "iPad7,5", "iPad7,6"                       then "iPad 6"
	      when "iPad11,4", "iPad11,5"                     then "iPad Air (3rd generation)"
	      when "iPad2,5", "iPad2,6", "iPad2,7"            then "iPad Mini"
	      when "iPad4,4", "iPad4,5", "iPad4,6"            then "iPad Mini 2"
	      when "iPad4,7", "iPad4,8", "iPad4,9"            then "iPad Mini 3"
	      when "iPad5,1", "iPad5,2"                       then "iPad Mini 4"
	      when "iPad11,1", "iPad11,2"                     then "iPad Mini 5"
	      when "iPad6,3", "iPad6,4"                       then "iPad Pro (9.7-inch)"
	      when "iPad6,7", "iPad6,8"                       then "iPad Pro (12.9-inch)"
	      when "iPad7,1", "iPad7,2"                       then "iPad Pro (12.9-inch) (2nd generation)"
	      when "iPad7,3", "iPad7,4"                       then "iPad Pro (10.5-inch)"
	      when "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4" then "iPad Pro (11-inch)"
	      when "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8" then "iPad Pro (12.9-inch) (3rd generation)"
	      when "AppleTV5,3"                               then "Apple TV"
	      when "AppleTV6,2"                               then "Apple TV 4K"
	      when "AudioAccessory1,1"                        then "HomePod"
	      else
	      	self.name
				end
  	end
	end
end