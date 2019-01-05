require 'parallel'
require_relative '../git/gitlab'
require_relative '../logger'

module Labor
	class ProjectHooksCleaner
		include Labor::GitLab
		include Labor::Logger

		def initialize(names = [])
			@names = Array(names).map(&:strip)
		end

		def clean
			# ====================== Delete project hooks ======================= #
			Parallel.each(fetch_specs(@names), in_threads: 8) do |name, project_id|
				delete_project_hook(name, project_id) do |hook|
					bool = true
					Labor::GitLabProxy::DEFAULT_PROJECT_HOOK_OPTIONS.each do |k, v|
						unless hook.send(k) == v
							bool = false
							break
						end
					end
					bool
				end
			end
			# ====================== Delete project hooks ======================= #
		end

		private

		def fetch_specs(names)
			specs = Labor::Specification.newest.without_third_party
				.select { |spec| names.empty? || names.include?(spec.name) }
				.map { |spec| { spec.name => spec.project_id } if spec.project_id }
				.compact
				.reduce({}) { |r, n| r.merge!(n) }
			specs
		end

		def delete_project_hook(name, project_id, &rejector)
			hooks = gitlab.client.project_hooks(project_id)  
			hooks = hooks.reject do |hook| 
				if block_given? 
					yield hook 
				else  
					false 
				end
			end 

			hooks.each do |hook|
				logger.info "[#{self.class}] > delete #{name}'s hook #{hook.id} #{hook.url}"
				gitlab.delete_project_hook(project_id, hook.id)
			end
		rescue => error
			logger.error "[#{self.class}] > failed to delete #{name}'s hooks with project id #{project_id}"
		end
	end
end