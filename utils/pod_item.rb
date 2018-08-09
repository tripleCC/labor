require 'cocoapods-external-pod-sorter'

class ExternalPodSorter
	class PodItem
		def repo_url
			dependency.external_source[:git] || spec.source[:git]
		end

		def ref
			dependency.external_source[:branch] 
		end
	end
end