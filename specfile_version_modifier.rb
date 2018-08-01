require 'cocoapods'
require 'cocoapods-external-pod-sorter'

module Labor
	class SpecfileVersionModifier
		class VersionInvalidError < ArgumentError; end

		attr_reader :refer_version

		def initialize(filepath, refer_version)
			@filepath = find_podspec(filepath)
			@specification = Pod::Specification.from_file(Pathname.new(@filepath))
			@refer_version = Pod::Version.new(refer_version)
		end

		def modify
			unless @refer_version == @specification.version
				validate!

				synchronize(@refer_version.to_s)
			end
		end

		def podspec_version
			@specification.version
		end

		def newest_version
			@newest_version ||= begin 
				source = Config.instance.sources_manager.default_source
				source.update(false)
				newest_version = source.versions(@specification.name).sort.last
			end
		end

		def validate!
			error = []
			error << "参考版本 #{@refer_version} 小于 podspec 文件中的版本 #{@specification.version}" unless @refer_version >= @specification.version 
			error << "参考版本 #{@refer_version} 小于私有源中最新的版本 #{newest_version}" unless @refer_version >= newest_version
			raise VersionInvalidError, error.join('; ') if error.any?
		end

		def synchronize(version)
			spec = ''
			File.open(@filepath, "r") do |file|  
        file.each_line do |line|
          if line.match('.*\\.version\s*={1}\s*["\'].*["\']')
            spec << line.split('.').first + ".version = \"#{version}\"\n"
          else
            spec << line  
          end
        end
      end

      File.open(@filepath, "w") do |io|  
        io << spec
      end

      spec
		end

		def find_podspec(path)
			Dir.glob(File.join(path, '*.podspec')).first
		end

	end
end