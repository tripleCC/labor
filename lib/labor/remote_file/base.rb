require 'cocoapods-tdfire-binary'
require_relative '../git/gitlab'
require_relative '../errors'

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
			rescue Gitlab::Error::NotFound => error
				# self.class.name.demodulize
				# [2..-1]
				raise Labor::Error::NotFound.new("Can't find #{self.class.name.split('::').drop(2).join('')} with error #{error.message}")
			end
		end
	end
end