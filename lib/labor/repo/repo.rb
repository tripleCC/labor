require 'fileutils'

module Labor
	class Repo
		attr_reader :absolute_path
		attr_reader :git_url

		def initialize(absolute_path, git_url)
			@absolute_path = absolute_path
			@git_url = git_url 
		end

		public

		def git
			@git ||= git_proxy
		end

		def copy(dest_absolute_path)
			FileUtils.rm_rf(dest_absolute_path)  if Dir.exist?(dest_absolute_path)
			dirname = File.dirname(dest_absolute_path)

			FileUtils.mkdir_p(dirname)
			FileUtils.cp_r(absolute_path, dirname)

			repo = Repo.new(dest_absolute_path, git_url)
			repo
		end

		def can_clone?
			!File.exist?(absolute_path)
		end

		def clone
			if can_clone?
				Git.clone(git_url, absolute_path)
			else
				git.pull_all
			end
			git

		# rescue => err
		# 	p err
		end

		def checkout_pull(branch, &block)
			recovery_branch = git.current_branch

			if branch != recovery_branch
				git.stash_save('stash before checkout.')
			  git.checkout(branch) 
			end

		  git.pull('origin', branch)

		  yield self if block_given?

		  if branch != recovery_branch
			  git.checkout(recovery_branch)
			  git.stash_apply
			end

		# rescue => err
		# 	p err
		end

		private
		
		def git_proxy
			# :log => Labor::Logger.logger
			git = Git.open(absolute_path)
		rescue => _
			git = Git.clone(git_url, absolute_path)
		ensure 
			return Labor::GitProxy.new(git)
		end
	end
end