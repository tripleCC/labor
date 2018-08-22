require 'git'

module Labor
	class MergeConflictError < Git::GitExecuteError; end

	class GitProxy

		class << self
			attr_accessor :silent
		end
		@silent = false

		attr_reader :git

		def initialize(git)
			@git = git
		end

		def pull_all
			git.chdir do 
				command = "git pull --all"
				exec_command command
			end
		end

		def push_current_branch
			git.push('origin', git.current_branch)
		end

		def conflict_files
			`git diff --diff-filter=U --name-only`
		end

		def merge(branch, message = nil)
			git.chdir do 
				command = "git merge #{branch}"
				command << " --no-ff -m '#{message}'" if message
				exec_command command

				files = conflict_files
				raise MergeConflictError, "以下文件合并冲突：#{files}" unless files.empty?
			end
		end

		def reset_hard_and_clean
			git.reset_hard
			git.clean({ force: true })
		end

		def add_and_commit(commit)
			git.add
			git.commit(commit) if %w[changed added deleted].reduce(false) { |r, n| r || git.status.send(n).any? }
		end

		def push_tag(tag)
			git.chdir do 
				command = "git push origin #{tag}"
				exec_command command
			end
		end

		def refresh_both_ends_tag(tag)
			git.delete_tag(tag) if git.tags.map(&:name).include?(tag)
			delete_remote_tag(tag)

			git.add_tag(tag)
			push_tag(tag)
		end

		def delete_remote_tag(tag)
			git.chdir do 
				command = "git push origin :#{tag}"
				exec_command command
			end
		end

		def stash_save(message)
			git.chdir do 
				git.lib.stash_clear
				git.lib.stash_save(message)
			end
		end

		def stash_apply
			git.chdir do 
				git.lib.stash_apply
			end if git.branch(git.current_branch).stashes.any?
		end

		def respond_to_missing?(method, include_private = false)
			git.respond_to?(method) || super
		end

		def method_missing(method, *args, &block)
			super unless git.respond_to?(method)
			git.send(method, *args)
		end

		private
		def exec_command(command)
			command << ' --quiet' if GitProxy.silent
			system command
		end
	end
end