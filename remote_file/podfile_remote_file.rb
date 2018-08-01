require 'cocoapods'
require_relative '../remote_file'

module Labor
	class PodfileRemoteFile < RemoteFile
		attr_reader :podfile

		def podfile
			@podfile ||= begin
				content = file_contents
				podfile = Pod::Podfile.from_ruby(nil, content)
				podfile
			end
		end
	end
end