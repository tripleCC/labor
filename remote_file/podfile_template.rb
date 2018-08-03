require 'cocoapods'
require_relative '../remote_file'

module Labor
	module RemoteFile
		class Podfile < Base
			class PodfileTemplate < Podfile
				PODFILE_TEMPLATE_NAME = 'PodfileTemplate'.freeze	

				def initialize(project_id, ref, path = nil)
					path ||= gitlab.file_path(project_id, PODFILE_TEMPLATE_NAME, ref)

					super project_id, ref, path
				end
			end
		end		
	end
end