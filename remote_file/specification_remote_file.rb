require 'cocoapods'
require_relative '../remote_file'
require_relative '../git/gitlab'

module Labor
	class SpecificationRemoteFile < RemoteFile
		attr_reader :specification

		def initialize(project_id, ref)
			super project_id, ref, podspec_path(project_id)
		end

		def specification
			@specification ||= begin
				specification = Pod::Specification.from_string(file_contents, @path)
				specification
			end
		end


		def modify_version(refer_version)
			modifier = SpecfileVersionModifier.new(file_contents, refer_version, @path)
			if modifier.should_modify? 
				content = modifier.modify
				gitlab.edit_file(pr.id, path, ref, content, "[ci skip] 更正 podspec 版本 #{refer_version}")
			end
		end

		private
		def podspec_path(project_id)
			tree = gitlab.tree(project_id).find do |tr| 
				tr.name.end_with?('.podspec') ||
				tr.name.end_with?('.podspec.json')
			end

			tree.path if tree
		end
	end
end