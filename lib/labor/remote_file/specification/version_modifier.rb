require 'cocoapods-core'
require_relative '../base'
require_relative '../../errors'

module Labor
	module RemoteFile
		class Specification < Base
			class VersionModifier

				attr_reader :refer_version
				attr_reader :specification

				def initialize(specification_string, refer_version, path)
					@specification_string = specification_string.encode('UTF-8')
					@path = path
					# specification from_string 需要一个路径
					@specification = Pod::Specification.from_string(@specification_string, @path || Pathname.new('Common.podspec'))
					@refer_version = Pod::Version.new(refer_version)
				end

				def should_modify?
					@refer_version != @specification.version
				end

				def modify(persist = false)
					if should_modify?
						validate!

						synchronize(@refer_version.to_s, persist)
					end
				end

				def podspec_version
					@specification.version
				end

				# 由前端填写，这里就不做限制了
				# def validate!
					# error = []
					# error << "#{@specification.name} 参考版本 #{@refer_version} 小于 podspec 文件中的版本 #{@specification.version}" unless @refer_version >= @specification.version 
					# error << "参考版本 #{@refer_version} 小于私有源中最新的版本 #{newest_version}" unless @refer_version >= newest_version
					# raise Labor::Error::VersionInvalid, error.join('; ') if error.any?
				# end


				def update_podspec_content(podspec_content, version)
					require_variable_prefix = true
					version_var_name = 'version'
					variable_prefix = require_variable_prefix ? /\w\./ : //
					version_regex = /^(?<begin>[^#]*#{variable_prefix}#{version_var_name}\s*=\s*['"])(?<value>(?<major>[0-9]+)(\.(?<minor>[0-9]+))?(\.(?<patch>[0-9]+))?(?<appendix>(\.[0-9]+)*)?(-(?<prerelease>(.+)))?)(?<end>['"])/i

					version_match = version_regex.match(podspec_content)
				  updated_podspec_content = podspec_content.gsub(version_regex, "#{version_match[:begin]}#{version}#{version_match[:end]}")
				  updated_podspec_content
				end

				def unit_increase_version(version, type)
				  major = version.major
				  minor = version.minor
				  patch = version.patch
				  case type
				  when 'major'
				    major += 1
				  when 'minor'
				    minor += 1
				  when 'patch'
				    patch += 1
				  else
				  end
				  Pod::Version.new("#{major}.#{minor}.#{patch}")
				end

				def synchronize(version, persist)
					updated_podspec_content = update_podspec_content(@specification_string, version)
		      if @path && persist
			      File.open(@path, "w") do |io|  
			        io << updated_podspec_content
			      end 
		    	end

		      updated_podspec_content
				end
			end
		end
	end
end