require 'cocoapods-core'
require 'rubygems'

module ExternalPod		
	class Item
		attr_accessor :name
		attr_accessor :external_dependency_names
		attr_accessor :dependency
		attr_accessor :spec

		def initialize(name)
			@name = name
		end

		def repo_url
			dependency.external_source[:git] || spec.source[:git]
		end

		def ref
			dependency.external_source[:branch] 
		end

		def version
			spec.version.to_s
		end

		def refer_version
			refer_version = Gem::Version.new(version)
			release_version = ref.split('/').last
			
			unless Gem::Version.correct?(release_version).nil?
				release_gem_version = Gem::Version.new(release_version) 	
				refer_version = release_gem_version if release_gem_version > refer_version
			end
			refer_version.to_s
		end

		def to_s
			name
		end

		def inspect
			name
		end
	end
end
