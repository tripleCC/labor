require_relative './base'
require_relative '../../logger'
require_relative '../../remote_file'

module ExternalPod
	class Sorter
		module DataSource
			class Remote < Base
				include Labor::GitLab
				include Labor::Logger

				def initialize(project_id, ref, podfile_path = nil)
					remote_file = Labor::RemoteFile::Podfile.new(project_id, ref, podfile_path)
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
					untagged_specs = []
					lock = Mutex.new
					# 过滤本地依赖
					untagged_git_dependencies = untagged_dependencies.select { |dep| dep.external_source[:git] }
					untagged_git_dependencies.map do |dep|
						th = Thread.new do
							git = dep.external_source[:git]
							ref = dep.external_source[:branch]
							# 这里后期再考虑 Podfile.lock 限定问题
							component_project = gitlab.project(git)
							remote_file = Labor::RemoteFile::Specification.new(component_project.id, ref)
							lock.synchronize do 
								untagged_specs << remote_file.specification
							end
						end
						th
					end.each(&:join)
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

							default_source.update(false)
							tagged_spec(dep)
						end
					end
					tagged_specs
				end 

				def tagged_spec(dep)
					version = default_source.versions(dep.root_name).sort.reverse.find do |v|
						dep.requirement.satisfied_by?(v)
					end
					spec = default_source.specification(dep.root_name, version)
					spec 
				end

				def default_source
				 Pod::Config.instance.sources_manager.default_source
				end
			end
		end
	end
end
