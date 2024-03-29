require 'cocoapods-core'

module Pod
	class Podfile
		def untagged_dependencies 
			# dependencies.select { |dependency| dependency.external? && dependency.external_source[:tag].nil?}
			
			main_target_definitions = target_definition_list.reject do |target_definition| 
				target_definition.name.end_with?('Tests') 
			end
			untagged_dependencies = main_target_definitions.flat_map(&:dependencies).uniq.select do |dependency| 
				dependency.external? && dependency.external_source[:tag].nil? 
			end
			untagged_dependencies
		end
	end
end