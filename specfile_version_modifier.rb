require 'cocoapods'
require 'cocoapods-external-pod-sorter'

module Labor
	class SpecfileVersionModifier
		class VersionInvalidError < ArgumentError; end

		attr_reader :refer_version

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

		def modify
			if should_modify?
				validate!

				synchronize(@refer_version.to_s)
			end
		end

		def podspec_version
			@specification.version
		end

		# def newest_version
		# 	@newest_version ||= begin 
		# 		source = Config.instance.sources_manager.default_source
		# 		source.update(false)
		# 		newest_version = source.versions(@specification.name).sort.last
		# 	end
		# end

		def validate!
			error = []
			error << "参考版本 #{@refer_version} 小于 podspec 文件中的版本 #{@specification.version}" unless @refer_version >= @specification.version 
			# error << "参考版本 #{@refer_version} 小于私有源中最新的版本 #{newest_version}" unless @refer_version >= newest_version
			raise VersionInvalidError, error.join('; ') if error.any?
		end

		def synchronize(version)
			spec = []
			@specification_string.split("\n").each do |line|  
        if line.match('.*\\.version\s*={1}\s*["\'].*["\']')
          spec << line.split('.').first + ".version = \"#{version}\"\n"
        else
          spec << line  
        end
      end

      spec_string = spec.join("\n")
      File.open(@path, "w") do |io|  
        io << spec_string
      end if @path

      spec_string
		end
	end
end