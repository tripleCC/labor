require_relative '../git/gitlab'

module Pod
	class Specification
		def self.from_remote(project_id, ref)
			gitlab = Labor::GitLab.gitlab
			
			# podspec 在根目录
			tree = gitlab.tree(project_id).find do |tr| 
				tr.name.end_with?('.podspec') ||
				tr.name.end_with?('.podspec.json')
			end

			podspec_path = tree.path if tree
			content = gitlab.file_contents(project_id, podspec_path, ref)	
			specification = from_string(content, podspec_path)
			specification
		end
	end
end
