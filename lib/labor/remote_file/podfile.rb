require 'cocoapods-core'
require_relative './base'

module Labor
	module RemoteFile
		class Podfile < Base

			PODFILE_NAME = 'Podfile'.freeze

			attr_reader :podfile

			def initialize(project_id, ref, path = nil)
				path ||= gitlab.file_path(project_id, PODFILE_NAME, ref)

				super project_id, ref, path
			end

			def podfile
				@podfile ||= begin
					content = file_contents
					podfile = Pod::Podfile.from_ruby(Pathname.new(path), content)
					podfile
				end
			end
		end
	end
end