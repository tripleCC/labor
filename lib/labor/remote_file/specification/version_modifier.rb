require 'cocoapods-core'
require_relative '../base'

module Labor
	module RemoteFile
		class Specification < Base
			class VersionModifier
				class VersionInvalidError < ArgumentError; end

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

				def validate!
					error = []
					error << "参考版本 #{@refer_version} 小于 podspec 文件中的版本 #{@specification.version}" unless @refer_version >= @specification.version 
					# error << "参考版本 #{@refer_version} 小于私有源中最新的版本 #{newest_version}" unless @refer_version >= newest_version
					raise VersionInvalidError, error.join('; ') if error.any?
				end

				def synchronize(version, persist)
					spec = []
					@specification_string.split("\n").each do |line|  
		        if line.match('.*\\.version\s*={1}\s*["\'].*["\']')
		          spec << line.split('.').first + ".version = \"#{version}\"\n"
		        else
		          spec << line  
		        end
		      end

		      spec_string = spec.join("\n")
		      if @path && persist
			      File.open(@path, "w") do |io|  
			        io << spec_string
			      end 
		    	end

		      spec_string
				end
			end
		end
	end
end