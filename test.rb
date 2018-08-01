#!/usr/bin/env ruby

require 'pp'
require 'gitlab'
require 'open3'
require 'fileutils'
require 'open-uri'
require 'git'
require 'logger'
require 'cocoapods'

# require_relative './cocoapods/specification'
# require_relative './cocoapods/sources_manager'
# require_relative './cocoapods/podfile'
# require_relative './external_pod_sorter'
include Pod

require 'cocoapods-external-pod-sorter'

require 'yaml'
# require_relative './member_reminder'
require_relative './labor'

# def test(name = nil, *argv)
# 	pp argv
# end

# test(1, 123)

# alias :real_test :test

# def test(name = nil, *argv)
# 	return if argv.last && argv.last.is_a?(Hash) && argv.last[:debug] == true
# 	real_test(name, *argv)
# end

# test 1, 2, :git => 121, :debug => true

# p ENV['DEBUG']
# module Labor
# 	module Logger
# 		def self.logger
# 			@logger = ::Logger.new(STDOUT)		
# 		end
# 	end
# end
# Labor::Logger.logger.info('232323')
# gitlab = Labor::GitLab.gitlab

# pr = gitlab.project('git@git.2dfire-inc.com:qingmu/PodA.git')
# pp gitlab.tags(pr.id).map(&:name)

# pp gitlab.create_tag(pr.id, '0.2.6', 'master')

# include Labor::GitLab

# def podfile_from_remote(project_id, path, ref)
# 	raise "#{path} 必须指名以 Podfile 所在路径" unless File.basename(path) == 'Podfile'

# 	content = gitlab.file_contents(project_id, path, ref)	
# 	podfile = Pod::Podfile.from_ruby(nil, content)
# 	podfile
# end

# def specification_from_remote(project_id, ref)
# 	# podspec 在根目录
# 	tree = gitlab.tree(project_id).find do |tr| 
# 		tr.name.end_with?('.podspec') ||
# 		tr.name.end_with?('.podspec.json')
# 	end

# 	podspec_path = tree.path if tree
# 	content = gitlab.file_contents(project_id, podspec_path, ref)	
# 	specification = Pod::Specification.from_string(content, podspec_path)
# 	specification
# rescue
# end
include Labor

gitlab = Labor::GitLab.gitlab
pr = gitlab.project('git@git.2dfire-inc.com:qingmu/PodA.git')

# project_id = pr.id 
ref = 'master'
refer_version = '1.3.0'


rf = SpecificationRemoteFile.new(pr.id, ref)
p rf.modify_version(refer_version)
# p file


# pr = Labor::GitLab.gitlab.project('git@git.2dfire-inc.com:ios/restapp.git')
# data_source = RemoteDataSource.new(pr.id, 'release/5.6.72', 'RestApp/Podfile')
# sorter = ExternalPodSorter.new(data_source)
# p sorter.sort
# sorter.grouped_pods.each do |group|
# 	group.each do |pod|
# 	  display = pod.name.dup
# 	  if pod.external_dependency_names.any?
# 	    pod.external_dependency_names.each do |name|
# 	      display << "\n- #{name}"
# 	    end
# 	  end
# 	  display << "\n\n"
# 	  puts display
# 	end
# end


# pr = gitlab.project('git@git.2dfire-inc.com:ios/restapp.git')
# podfile = podfile_from_remote(pr.id, 'RestApp/Podfile', 'release/5.6.72')

# untagged_dependencies = podfile.untagged_dependencies

# # 不需要分析已经打好 tag 的
# tagged_dependencies = podfile.dependencies - untagged_dependencies

# source = Config.instance.sources_manager.default_source


# tagged_spec = tagged_dependencies.uniq { |dep| dep.root_name }.map do |dep|
# 	version = source.versions(dep.root_name).sort.reverse.find do |v|
# 		dep.requirement.satisfied_by?(v)
# 	end
# 	spec = source.specification(dep.root_name, version)
# 	spec 
# end

# # return 

# untagged_specs = Concurrent::Array.new
# pool = Concurrent::CachedThreadPool.new
# untagged_dependencies.each do |dep|
# 	pool.post do
# 		git = dep.external_source[:git]
# 		ref = dep.external_source[:branch]

# 		# 这里后期再考虑 Podfile.lock 限定问题
# 		component_project = gitlab.project(git)
# 		spec = specification_from_remote(component_project.id, ref)

# 		untagged_specs << spec 
# 	end
# end
# pool.shutdown
# pool.wait_for_termination


# pp untagged_specs





# pr = gitlab.project('git@git.2dfire-inc.com:qingmu/PodA.git')
# pp specification(pr.id, 'master').to_hash

# content = gitlab.file_contents(pr.id, 'RestApp/Podfile', 'release/5.6.72')
# podfile = Podfile.from_ruby(nil, content)
# untagged_dependencies = podfile.untagged_dependencies

# untagged_dependencies.map do |dep|
# 	dep.name
# 	git = dep.external_source[:git]
# 	ref = dep.external_source[:branch]

# 	gitlab.project('git@git.2dfire-inc.com:ios/restapp.git')
# 	p ref
# end
# pp pr

# pp gitlab.client.create_tag(p.id, '0.2.4', '95a8577e1d10b1d9009842699c2fca0374a1a00f')
# gitlab.create_merge_request(p.id, 'test', '青木', { source_branch: 'develop', target_branch: 'master' })
# triggered_info = gitlab.run_default_trigger(p.id, '0.2.5')

# p triggered_info
# p triggered_info
# p triggered_info

# target = gitlab.client.tags(p.id).find { |t| t.name == '0.2.3' }
# p target
# pp gitlab.client.branches(p.id).find { |t| t.name == 'master' }

# pp target.commit.id 


# hook_url = 'https://api.example.net/v1/webhooks/ci'

# pp gitlab.add_project_hook(p.id, hook_url)

# gitlab.client.add_project_hook(p.id, 'https://api.example.net/v1/webhooks/ci')

# pp target

# same_pipelines = gitlab.client.pipelines(p.id, { per_page: 10 }).first
# p same_pipelines
# .select do |pl|
# 	%w[pending running created manual].include?(pl.status) &&
# 	pl.sha == triggered_info.sha &&
# 	pl.ref == triggered_info.ref
# end

# same_pipelines.pop
# if same_pipelines.any?
# 	p same_pipelines
# 	same_pipelines.each { |pl| gitlab.client.cancel_pipeline(p.id, pl.id)  }
# end


# '../'

# Dir.chdir('PodA') do 
# 	'../PodA'
# end


# Process.new do 
# 	Dir
# end

# # `cd PodA`

# # `cd ..`

# '../'

# modifier = Labor::SpecfileVersionModifier.new('./TDFTakeOutModule.podspec', '0.3.1')
# modifier.modify
# git = Git.open('./PodA', :log => Logger.new(STDOUT))
# git.pull
# p git.branches.map(&:name)
# p git.tags.map(&:name)
# p git.branch('master').stashes

# p git.current_branch
# p git.branch('master')
# git.chdir do 
# 	p git.lib.stash_save('as')
# end


# p git.branch('master').stashes.any?
# git.chdir do 

# 	git.lib.stash_apply
# end

# Labor::GitProxy.silent = true
# Labor::TaskExecuter.new('123', 'git@git.2dfire-inc.com:qingmu/PodA.git', 'release/0.2.3', '0.2.3').execute

# Git::Stash.new()


# p git.methods.select { |m| m.to_s.start_with?('sta') }
# git.delete_tag('0.0.1')
# proxy = GitProxy.new(git)
# p proxy.branches


# m = MemberReminder::MemberBank.new('./test.yml')




# manager = RepoManager.instance
# manager.main_cache.create_or_update_repo('git@git.2dfire-inc.com:qingmu/PodA.git')

# manager.main_cache.copy_repo('./temp1', 'git@git.2dfire-inc.com:qingmu/PodA.git')

# g = Git.open('./TDFAddressFetcher')
# p g.current_branch



# class RepoShadow

# end

# updater.update


# ts = 10.times.map do |i|
# 	Thread.new do
# 		unless Dir.exist?('TDFAddressFetcher')
# 			begin
# 				g = Git.clone('git@git.2dfire-inc.com:qingmu/TDFAddressFetcher.git', './TDFAddressFetcher')
# 			rescue Git::GitExecuteError => err 
# 				p err
# 			end
# 		else
			# g = Git.open('./TDFAddressFetcher')
# 			g.pull
# 		end
# 	end
# end
# ts.each(&:join)

# m.post(m.members.select { |m| m.name == '青木' || m.name == '紫薯' }, '啦啦')
# p m.teams

# p YAML.load_file('test.yml').to_hash


# config = Config.instance
# podspec = Specification.from_file(Pathname.new('TDFTakeOutModule.podspec'))
# podfile = Podfile.from_file(Pathname.new('Podfile'))

# sorter = ExternalPodSorter.new
# sorter.sort
# sorter.sort

# p sorter.grouped_pods
# .each do |pod|
# 	# puts pod
# end

# pp podfile.untagged_dependencies



# specs = Config.instance.sources_manager.default_source.newest_specs
# pp podspec.recursive_dependencies(specs)


# ts = []
# 10.times do 
# 	t = Thread.new do 
# 		git = Git.open('/Users/songruiwang/Work/TDF/ci-status-server')
# 		pp git.branches.map(&:to_s)
# 	end
# 	ts << t
# end
# ts.each(&:join)



# ts = 10.times.map do |int|
# 	Thread.new do 
# 		Open3.popen3("pwd", :chdir=>"temp") { |i,o,e,t|

# 			p Dir.pwd
# 			Open3.popen3("pwd", :chdir=>"temp/temo") { |i,o,e,t|
# 				# p o.read.chomp
# 				# p i
# 			}
# 	  	# p o.read.chomp
# 	  	# p
# 		}


# 	end
# end

# ts.each(&:join)

# if false
#     a = 1 
# end
# p a

# Gitlab.configure do |config|
#     config.endpoint       = 'http://git.2dfire-inc.com/api/v4' 
#     # qingmu's token
#     config.private_token  = 'Se79zS8rgUupDZv6JN8G'  
# end


# r = Net::HTTP.get_response(URI.parse("http://git.2dfire-inc.com/rest-client/usage-documentation/raw/master/package.json"))
# pp r.body

# file = open('http://git.2dfire-inc.com/ios/ci-yaml-shell/raw/master/boss_keeper_members.yml')
# pp file.read

# file = File.open('boss_keeper_members.yml')
# file = File.join(File.dirname(__FILE__), 'boss_keeper_members.yml')
# pp  YAML.load(file)
# project = Gitlab.project_search('RestApp').select { |p| p.name == 'RestApp' }.first
 
# KEEPED_BRANCHES = %w[master develop CI].freeze

# all_branches = []
# branches = Gitlab.branches(project.id, { per_page: 100 })
#  loop do
#  	all_branches += branches	
# 	break unless branches.has_next_page?
# 	branches = branches.next_page
# end

# delete_branches = all_branches.select do |br| 
# 	(br.merged && ((Time.new - Time.parse(br.commit.created_at)) / 3600 / 24 / 7) > 1 ||
# 	((Time.new - Time.parse(br.commit.created_at)) / 3600 / 24 / 7) > 5) &&
# 	!KEEPED_BRANCHES.include?(br.name)
# end

# delete_branches.each do |br|
# 	Gitlab.delete_branch(project.id, br.name)
# end


# all_triggers = []
# triggers = Gitlab.triggers(project.id)
#  loop do
#  	all_triggers += triggers	
# 	break unless triggers.has_next_page?
# 	triggers = triggers.next_page
# end
# p all_triggers.size


# # 删除旧的 cron triggers
# all_triggers.select { |tr| tr.description == 'ci cron job' }.each do |tr|
# 	Gitlab.remove_trigger(project.id, tr.id)
# end

# 运行日常 CI
# daily_trigger = all_triggers.select { |tr| tr.description == 'ci daily job' }.first
# daily_trigger = Gitlab.create_trigger(project.id, 'ci daily job') if daily_trigger.nil?
# Gitlab.run_trigger(project.id, daily_trigger.token, 'master')   




# pp Gitlab.runners
# # Gitlab.users 返回的 user 不完整
# user_name = '青木' 


# p Gitlab.users.map(&:name)
# p Gitlab.groups.map(&:name)
                    # .flat_map { |g| Gitlab.group_members(g.id) }
                    # .uniq! { |u| u.id }
                    # .map(&:name)

# project_name = 'TDFNetworking'
# require 'pp'

# pp Gitlab.project_search('TDFCore').first.to_hash


# all_users = []

# users = Gitlab.users({per_page: 2})

# pp users
# loop do
# 	break unless users.has_next_page?
# 	users = users.next_page
# 	all_users += users	
# end

# pp all_users.select { |user| user.name == '青木' }.first
# require 'pp'
# pp Gitlab.groups.flat_map { |g| Gitlab.group_members(g.id) }

# p project
# begin
#     trigger = Gitlab.create_trigger(project.id, 'ci cron job')
#     Gitlab.run_trigger(project.id, trigger.token, 'master')   
# rescue Gitlab::Error::BadRequest
#     p 'kkkkkk'
# rescue => exception
#     p exception
# end

# p project.namespace.name
# p Gitlab.create_merge_request(project.id, "CI merge conflict", {
#         source_branch: 'develop',
#         target_branch: 'master',
#         assignee_id: user.id
#       })

# p Gitlab.merge_requests(project.id).select { |m| 
# 	m.state == 'opened' &&
# 	m.title == 'CI merge conflict' 
# 	m.target_branch == 'master'
# 	m.source_branch == 'develop'
# }.first.web_url

# p Gitlab.group_members(cocoapods_repos_group_id).map(&:name)
