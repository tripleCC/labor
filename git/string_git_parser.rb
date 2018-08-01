module StringGitParser
	refine String do 
		def git_name 
			match('/(.*).git')[1]
		end
	end
end