require 'cocoapods-core'
require_relative '../base'

module Labor
	module RemoteFile
		class Podfile < Base 
			class Generator
				DEFAULT_LABEL = 'TRIPLECCREPLACEME'.freeze

				attr_reader :podfile_string

				def initialize(podfile, podfile_template_string) 
					@podfile = podfile
					@podfile_template_string = podfile_template_string
				end

				def generate
					@podfile_string = ''

					@podfile_template_string.split("\n").each do |line|
						if line.strip.match(DEFAULT_LABEL)
							@podfile.dependencies.each do |dep|
								@podfile_string << "  pod '#{dep.name}'"
								@podfile_string << ", '#{dep.requirement.to_s}'" unless dep.requirement.none?

								if dep.external? && dep.external_source[:branch]
									@podfile_string << ", '= #{dep.external_source[:branch].split('/').last}'" if dep.external_source[:branch].start_with?('release/')
								end

								@podfile_string << "\n"
							end
						else 
							@podfile_string << line 
							@podfile_string << "\n"
						end
					end

					@podfile_string					
				end
			end
		end
	end
end