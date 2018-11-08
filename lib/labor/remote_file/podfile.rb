require 'cocoapods-core'
require_relative './base'
require_relative './podfile/template'
require_relative './podfile/generator'
require_relative '../git/string_extension'

module Labor
	module RemoteFile
		class Podfile < Base
			using StringExtension
			
			PODFILE_NAME = 'Podfile'.freeze

			attr_reader :podfile

			def initialize(project_id, ref, path = nil)
				path ||= gitlab.file_path(project_id, podfile_name, ref)
				super project_id, ref, path
			end

			def podfile
				@podfile ||= begin
					content = file_contents
					podfile = Pod::Podfile.from_ruby(Pathname.new(path), content)
					podfile
				end
			end

			def template
				@template ||= begin 
					Template.new(@project_id, @ref)
				end 
			end

			def edit_remote(versions = [])
				podfile_string = Generator.new(podfile, template.file_contents, versions).generate
				gitlab.edit_file(@project_id, @path, @ref, podfile_string, "封板#{ref}".ci_skip) unless file_contents == podfile_string
			end

			protected
			def podfile_name 
			 PODFILE_NAME
			end
		end
	end
end