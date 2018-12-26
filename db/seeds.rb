require_relative '../lib/labor/models/specification'
require_relative '../lib/labor/external_pod/sorter'
require 'benchmark'
require 'member_reminder'

source = Pod::Config.instance.sources_manager.default_source

puts "start create specifications (last 1)"
# benchmark = Benchmark.measure {
# 	#https://pg.sjk66.com/postgresql/select-distinct
# 	Labor::Specification.newest.third_party.each do |s|
# 		# puts s.project if s.project
# 		puts "#{s.project&.name}" if s.project
# 	end
# 	# Labor::Specification.where(third_party: false).order({ name: :asc, version: :desc }).group_by(&:name).each do |name, value|
# 		# p s.first
# 	# end
# }

# puts benchmark

# all = Labor::Specification.where(id: Labor::Specification.newest.without_third_party).with_project.order(owner: :asc)

# puts all
# return 

bank = MemberReminder::MemberBank.new

benchmark = Benchmark.measure {
	Parallel.each(source.pods, in_threads: 8) do |pod|
		versions = source.versions(pod)
		versions.sort.last.tap do |version|
			# Specification.from_string 会 chdir ！
			spec = source.specification(pod, version)
			spec_path = source.specification_path(pod, version)
			spec_content = File.read(spec_path)
			ActiveRecord::Base.connection_pool.with_connection do
			 	Labor::Specification.create_or_update_specification_by(pod, version.to_s, spec_content, spec) do |spec|
					if spec.authors
						member = bank.member_of_authors(spec.authors) 
						owner = member&.name || spec.authors.keys.first
						spec.owner = owner
						spec.team = member&.team&.name if member&.team
					end
			 	end
		  end
			# p "create or update specification #{pod} #{version}"
		end
	end
}
puts "finish create specifications (last 1) with benchmark #{benchmark}"
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