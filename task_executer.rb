require_relative './repo/repo_manager'
require_relative './specfile_version_modifier'
require_relative './logger'

module Labor
	class TaskExecuter
		include Logger

		def initialize(identifier, git_url, branch, version = nil)
			@identifier = identifier
			@git_url = git_url
			@branch = branch
			@version = version || @branch.split('/').last
		end

		def prepare(identifier, git_url)
			main_repo = Labor::Repo::Manager.instance.main_cache.repo(git_url)

			logger.info("更新主缓存中仓库 #{git_url}")
			main_repo.clone

			repo_cache = Labor::Repo::Cache.new(identifier)
			absolute_path = repo_cache.repo_absolute_path(git_url)

			logger.info("拷贝目标仓库 #{absolute_path}")
			repo = main_repo.copy(absolute_path)
			repo
		end

		def execute
			repo = prepare(identifier, git_url)

			logger.info("切换目标分支 #{@branch}，拉取最新代码")
			repo.checkout_pull(@branch) do |r|

				modifier = Labor::SpecfileVersionModifier.new(repo.absolute_path, @version)

				logger.info("查看更改 podspec，目标版本 #{@version} podspec版本 #{modifier.podspec_version} 私有源最新版本 #{modifier.newest_version} ")
				modifier.modify

				logger.info("提交更改信息 #{@branch}，忽略 CI")
				r.git.add_and_commit("[ci skip] update podspec version to #{@version}")
				r.git.push_current_branch
			end

			logger.info("回到主分支，拉取最新代码")
			repo.git.pull

			logger.info("合并目标分支 #{@branch}")
			repo.git.merge(@branch, "[ci skip] merge #{@branch} into master")

			logger.info("更新 #{@git_url} tag #{@version}")
			repo.git.refresh_both_ends_tag(@version)

		end
	end
end