require 'cocoapods-external-pod-sorter'
require_relative './thread_pool'
require_relative './config'
require_relative './remote_file/podfile_remote_file'
require_relative './remote_file/specification_remote_file'

module Labor
	class RemoteDataSource < ExternalPodSorter::DataSource
		include Labor::GitLab
		include Labor::ThreadPool
		include Labor::Config::Mixin
		include Labor::Logger

		def initialize(project_id, ref, podfile_path = nil)
			remote_file = Labor::PodfileRemoteFile.new(project_id, ref, podfile_path)
			@podfile = remote_file.podfile
		end

		def untagged_dependencies
			@podfile.untagged_dependencies
		end

		def reference_specifications
			untagged_specs + tagged_specs
		end

		private 

		def untagged_specs
			untagged_specs = Array.new
			untagged_dependencies.each do |dep|
				cache_thread_pool.post do
					git = dep.external_source[:git]
					ref = dep.external_source[:branch]
					# 这里后期再考虑 Podfile.lock 限定问题
					component_project = gitlab.project(git)
					remote_file = Labor::SpecificationRemoteFile.new(component_project.id, ref)
					untagged_specs << remote_file.specification
				end
			end
			cache_thread_pool.shutdown
			cache_thread_pool.wait_for_termination
			untagged_specs
		end

		def tagged_specs
			tagged_dependencies = @podfile.dependencies - untagged_dependencies
			tagged_specs = tagged_dependencies.uniq { |dep| dep.root_name }.map do |dep|
				begin
					tagged_spec(dep)
				rescue ArgumentError => error
					# `retry` keywords also helps there
					logger.error("fail to get specification with error #{error}, update private source and try again.")

					config.default_source.update(false)
					tagged_spec(dep)
				end
			end
			tagged_specs
		end 

		def tagged_spec(dep)
			version = config.default_source.versions(dep.root_name).sort.reverse.find do |v|
				dep.requirement.satisfied_by?(v)
			end
			spec = config.default_source.specification(dep.root_name, version)
			spec 
		end
	end
end