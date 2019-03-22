require 'cocoapods-core'
require_relative '../git/string_extension'
require_relative '../logger'
require_relative './base'
require_relative './specification/version_modifier'

module Labor
	module RemoteFile
		class Specification < Base
			include Labor::Logger

			using StringExtension

			SPECIFICATION_EXTNAMES = ['.podspec', '.podspec.json'].freeze
			EXCLUDE_SPECIFICATION_EXTNAMES = ['.binary-template.podspec'].freeze

			attr_reader :specification

			def initialize(project_id, ref, path = nil)
				path ||= podspec_path(project_id, ref)

				super project_id, ref, path
			end

			def specification
				@specification ||= begin
					specification = Pod::Specification.from_string(file_contents, @path)
					specification
				end
			end

			def edit_remote_version(version = nil) 
				version ||= @ref.version

				modifier = VersionModifier.new(file_contents, version, @path)
				if modifier.should_modify? 
					logger.info("update #{specification.name} podspec version #{specification.version} to #{version}")
					content = modifier.modify
					gitlab.edit_file(@project_id, @path, @ref, content, "更正 podspec 版本 #{version}".ci_skip)
				end
			end

			private
			def podspec_path(project_id, ref)
				file_path = gitlab.find_file_path(project_id, ref) do |name| 
					next if EXCLUDE_SPECIFICATION_EXTNAMES.find { |extname| name.end_with?(extname) }
					SPECIFICATION_EXTNAMES.find { |extname| name.end_with?(extname) } 
				end
				file_path
			end
		end
	end
end