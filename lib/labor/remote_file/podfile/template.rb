require 'cocoapods-core'
require_relative '../base'

module Labor
	module RemoteFile
		class Podfile < Base 
			class Template < Podfile
				PODFILE_TEMPLATE_NAME = 'PodfileTemplate'.freeze	

				def podfile_name
					 PODFILE_TEMPLATE_NAME
				end
			end
		end
	end
end