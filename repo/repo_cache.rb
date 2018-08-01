require_relative './repo'
require_relative '../git/string_git_parser'

module Labor
	class Repo
		class Cache
			using StringGitParser

			WORKSPACE = '~/.repo-manager'.freeze

			attr_reader :root

			def initialize(directory)
				@root = File.expand_path(File.join(WORKSPACE, directory))
			end

			def repo_absolute_path(git_url)
				File.expand_path(File.join(@root, git_url.git_name))
			end

			def repo(git_url)
				repo = Repo.new(repo_absolute_path(git_url), git_url)
				repo
			end
		end
	end
end