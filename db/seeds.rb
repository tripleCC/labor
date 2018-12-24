require_relative '../lib/labor/models/specification'
require_relative '../lib/labor/external_pod/sorter'
require 'benchmark'

source = Pod::Config.instance.sources_manager.default_source

puts "start create specifications (last 2)"
benchmark = Benchmark.measure {
	Parallel.each(source.pods, in_processes: 8) do |pod|
		versions = source.versions(pod)
			versions.sort.last(2).each do |version|
				# Specification.from_string 会 chdir ！
				spec = source.specification(pod, version)
				spec_path = source.specification_path(pod, version)
				spec_content = File.read(spec_path)
				# p "create or update specification #{pod} #{version}"
				@reconnected ||= Labor::Specification.connection.reconnect! || true
    		Labor::Specification.create_or_update_specification_by(pod, version.to_s, spec_content, spec)
			end
	end
}
puts "finish create specifications (last 2) with benchmark #{benchmark}"
# Labor::Specification.transaction do
# 	source.pods.each do |pod|
# 		versions = source.versions(pod)
# 		versions.each do |version|
# 			spec = source.specification(pod, version)
# 			spec_path = source.specification_path(pod, version)
# 			spec_content = File.read(spec_path)
# 			p "create or update specification #{pod} #{version}"
# 			Labor::Specification.create_or_update_specification_by(pod, version.to_s, spec_content, spec)
# 		end
# 	end
# end