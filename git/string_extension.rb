module StringExtension
	refine String do 
		def git_name 
			match('/(.*).git')[1]
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
	end
end