require 'cocoapods'
require_relative '../remote_file'
require_relative '../git/gitlab'
require_relative './specification_remote_file/version_modifier'

module Labor
	class SpecificationRemoteFile < RemoteFile

		SPECIFICATION_EXTNAMES = ['.podspec', '.podspec.json'].freeze

		attr_reader :specification

		def initialize(project_id, ref, path = nil)
			path ||= podspec_path(project_id)

			super project_id, ref, path
		end

		def specification
			@specification ||= begin
				specification = Pod::Specification.from_string(file_contents, @path)
				specification
			end
		end


		def modify_version(refer_version)
			modifier = VersionModifier.new(file_contents, refer_version, @path)
			if modifier.should_modify? 
				content = modifier.modify
				gitlab.edit_file(@project_id, @path, @ref, content, "[ci skip] 更正 podspec 版本 #{refer_version}")
			end
		end

		private
		def podspec_path(project_id)
			file_path = gitlab.find_file_path(project_id) do |name| 
				SPECIFICATION_EXTNAMES.find { |extname| name.end_with?(extname) }
			end
			file_path
		end
	end
end