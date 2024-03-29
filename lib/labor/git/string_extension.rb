module StringExtension
	refine String do 
		def git_name
			split('/')&.last&.split('.')&.first
		end

		def ci_skip
			'[ci skip] ' + self
		end

		def is_master?
			self == 'master'
		end

		def is_develop?
			self == 'develop'
		end

		def has_version?
			start_with?('release/') ||
			start_with?('hotfix/')
		end

		def version
			split('/').last
		end
	end
end