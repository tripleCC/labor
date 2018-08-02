require 'cocoapods'
require_relative '../remote_file'

module Labor
	class PodfileRemoteFile < RemoteFile

		PODFILE_NAME = 'Podfile'.freeze

		attr_reader :podfile

		def initialize(project_id, ref, path = nil)
			path ||= gitlab.file_path(project_id, PODFILE_NAME)

			super project_id, ref, path
		end

		def podfile
			@podfile ||= begin
				content = file_contents
				podfile = Pod::Podfile.from_ruby(nil, content)
				podfile
			end
		end
	end
end