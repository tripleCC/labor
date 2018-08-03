require_relative './git/gitlab'

module Labor
	module RemoteFile 
		class Base
			include GitLab

			attr_reader :project_id
			attr_reader :ref
			attr_reader :path						
			attr_reader :file_contents

			def initialize(project_id, ref, path)
				@project_id = project_id
				@ref = ref 
				@path = path
			end

			def file_contents
				@file_contents ||= gitlab.file_contents(@project_id, @path, @ref)
			end
		end
	end
end