require_relative '../git/gitlab'

module Pod
	class Podfile
		def self.from_remote(project_id, path, ref)
			raise "#{path} 必须指名以 Podfile 所在路径" unless File.basename(path) == 'Podfile'

			content = Labor::GitLab.gitlab.file_contents(project_id, path, ref)	
			podfile = from_ruby(nil, content)
			podfile
		end
	end
end
