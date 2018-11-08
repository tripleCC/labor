require 'cocoapods-core'
require_relative '../base'

module Labor
	module RemoteFile
		class Podfile < Base 
			class Generator
				DEFAULT_LABEL = 'TRIPLECCREPLACEME'.freeze

				attr_reader :podfile_string

				def initialize(podfile, podfile_template_string, versions = []) 
					# TODO: 传入 versions 来设置版本，而不是通过 branch
					@podfile = podfile
					@versions = versions
					@podfile_template_string = podfile_template_string
				end

				def generate
					@podfile_string = ''

					@podfile_template_string.split("\n").each do |line|
						if line.strip.match(DEFAULT_LABEL)
							@podfile.dependencies.each do |dep|
								# 本地依赖直接跳过
								next if dep.external? && dep.external_source[:path]

								@podfile_string << "  pod '#{dep.name}'"
								if !dep.requirement.none?
									# 原来依赖版本的
									@podfile_string << ", '#{dep.requirement.to_s}'"
								elsif dep.external?
									# 需要发布的
									version = @versions[dep.name] || 
										(dep.external_source[:branch]&.start_with?('release/') && dep.external_source[:branch].split('/').last)
									@podfile_string << ", '= #{version}'" if version
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