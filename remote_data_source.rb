require_relative './thread_pool'

class ExternalPodSorter
	class RemoteDataSource < DataSource
		include Labor::ThreadPool

		def initialize(project_id, podfile_path, ref)
			@podfile = Pod::Podfile.from_remote(project_id, podfile_path, ref)
		end

		def untagged_dependencies
			@podfile.untagged_dependencies
		end

		def reference_specifications
			untagged_specs + tagged_spec
		end

		private 

		def untagged_specs
			untagged_specs = Array.new
			untagged_dependencies.each do |dep|
				thread_pool.post do
					git = dep.external_source[:git]
					ref = dep.external_source[:branch]

					# 这里后期再考虑 Podfile.lock 限定问题
					component_project = Labor::GitLab.gitlab.project(git)
					spec = Pod::Specification.from_remote(component_project.id, ref)
					untagged_specs << spec 
				end
			end
			thread_pool.shutdown
			thread_pool.wait_for_termination
			untagged_specs
		end

		def tagged_spec
			tagged_dependencies = @podfile.dependencies - untagged_dependencies
			tagged_spec = tagged_dependencies.uniq { |dep| dep.root_name }.map do |dep|
				source = Config.instance.sources_manager.default_source
				version = source.versions(dep.root_name).sort.reverse.find do |v|
					dep.requirement.satisfied_by?(v)
				end
				spec = source.specification(dep.root_name, version)
				spec 
			end
			tagged_spec
		end 
	end
end