require 'cocoapods-core'

class ExternalPodSorter
	class PodItem
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

		def to_s
			name
		end

		def inspect
			name
		end
	end
end