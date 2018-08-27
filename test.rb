#!/usr/bin/env ruby
# $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '.'))
require_relative './lib/labor'
# require 'state_machines-activerecord'
# require_relative './app'
# require_relative './models/pod_deploy'
# require_relative './models/main_deploy'
# include Labor

 
# pod_deploy.merge_request_iids << 1
# p deploy.pod_deploys.first.merge_request_iids
# pod_deploy.save

# p pod_deploy.merge_request_iids
# p deploy
# p deploy.status
# deploy.enqueue

# p Deploy.create(name: 'qingmu', repo_url: 'git@git.2dfire-inc.com:qingmu/PodE.git')
# require 'sinatra'

# get '/' do 
# 	
# end
require 'pp'


# pr = Labor::GitLab.gitlab.project('git@git.2dfire-inc.com:qingu/PodE.git')
# p pr

Labor::GitLab.gitlab.delete_tag('2441', '0.36')
# p Labor::GitLab.gitlab.newest_active_pipeline('2441', '0.34')
p Labor::GitLab.gitlab.create_tag('2441', '0.36', 'master')
sleep(0.15)
p Labor::GitLab.gitlab.create_pipeline('2441', '0.36')
file = Labor::RemoteFile::GitLabCIYaml.new('2441', 'release/0.2.3')
p file.config.keys
# data_source = ExternalPod::Sorter::DataSource::Remote.new(pr.id, 'release/0.0.1')
# sorter = ExternalPod::Sorter.new(data_source)
# pp sorter.sort

# 
# require 'gitlab'
# require_relative './hook_event_handler/merge_request'
# require_relative './hook_event_handler/pipeline'
# require_relative './hook_event_handler/push'

# MainDeploy.all.each(&:destroy)
# PodDeploy.all.each(&:destroy)
# main_deploy = MainDeploy.create(
# 		name: '发布1.6.5', 
# 		repo_url: 'git@git.2dfire-inc.com:qingmu/PodE.git', 
# 		ref: 'release/0.0.1'
# 		)

# main_deploy.pod_deploys = 5.times.map { |i|
# 	i = i.to_s
# 	deploy_hash = {
# 						name: i,
# 						repo_url: i,
# 						ref: i
# 					}
# 	d = PodDeploy.create(deploy_hash)
# 	d
# }

# main_deploy.pod_deploys.map do |d|
# 	Thread.new do 
# 		# main_deploy = MainDeploy.find_by(id: main_deploy.id)
# 		# p d
# 		d.update(name: 'kkkkk')
# 	end
# end.each(&:join)

# p PodDeploy.all.map(&:name)
# main_deploy.prepare

# p Labor::HookEventHandler.constants.map(&:to_s).map(&:underscore)
# p Labor::HookEventHandler::MergeRequest.event_name
# p "startMenuIconCls".underscore
# return
# MainDeploy.all.each(&:destroy)
# d = MainDeploy.create(
# 				name: 'i', 
# 				repo_url: 'git@git.2dfire-inc.com:qingmu/PodE.git', 
# 				ref: 'release/0.0.1'
# 				)
# d.prepare

# 10.times.map do |i|
# 	t = Thread.new do 
# 		d = MainDeploy.create(
# 				name: 'i', 
# 				repo_url: 'git@git.2dfire-inc.com:qingmu/PodE.git', 
# 				ref: 'release/0.0.1'
# 				)
# 		p d
# 		p d.update(ref: i.to_s)
# 		p d.update(name: i.to_s)

# 		# p d.enqueue
# 		# p d.deploy
# 		# p d.status
# 	end
# 	t
# end.each(&:join)

#(:lower)
# require 'sinatra'
# require 'sinatra/activerecord'

# post '/' do 
# 	hook_string = request.body.read
# 	hash = JSON.parse(hook_string)
# 	# pp hash
# 	object_kind = hash['object_kind']

# 	if Labor::HookEventHandler.event_kinds.include?(object_kind)
# 		handler = Labor::HookEventHandler.handler(object_kind, hash)
# 		handler.handle
# 	end

# 	''
# end

# get '/' do 
# 	# p PodDeploy.where(project_id: 2441, ref: 'release/0.2.3').find { |deploy| deploy.merge_request_iids.include?('30') }
# 	PodDeploy.all.each(&:destroy)
# 	MainDeploy.all.each(&:destroy)
# 	main_deploy = MainDeploy.find_or_create_by(
# 		name: '发布1.6.5', 
# 		repo_url: 'git@git.2dfire-inc.com:qingmu/PodE.git', 
# 		ref: 'release/0.0.1'
# 		)

# 	main_deploy.enqueue
 
#   # p main_deploy

# 	# p MainDeploy.all.size
# 	# deploy = MainDeploy.first
# 	# PodDeploy.all.each do |deploy|
# 	# 	p deploy
# 	# 	p deploy.merge_request_iids
# 	# end
# 	''
# end

# get '/deploys/main/' do 

# end

# get '/deploys/pod/' do 

# end


# get '/podDeploys' do 
# 	d = PodDeploy.all.select { |d| d.name == 'PodB' }.first
# 	d.enqueue
# 	# PodDeploy.all.each(&:enqueue)
# 	# p PodDeploy.pluck('status')	
# 	# p PodDeploy.pluck('name')
# 	''
# end

# get '/reviewed/:id' do 
# 	deploy = Labor::PodDeploy.find_by(id: params['id'])
# 	deploy.update(reviewed: true)
# 	deploy.auto_merge
# 	''
# end


# gitlab = Labor::GitLab.gitlab
# project = gitlab.project('git@git.2dfire-inc.com:qingmu/PodD.git')
# p gitlab.cancel_pipeline(project.id, gitlab.pipelines(project.id).first.id)
# pp gitlab.branch(project.id, "release/0.0.1")



# return 0

require 'pp'
require 'gitlab'
require 'open3'
require 'fileutils'
require 'open-uri'
require 'git'
require 'logger'
# require 'cocoapods'

# require_relative './cocoapods/specification'
# require_relative './cocoapods/sources_manager'
# require_relative './cocoapods/podfile'
# require_relative './external_pod_sorter'
# include Pod

# require 'cocoapods-external-pod-sorter'

require 'yaml'
# require_relative './member_reminder'
# require_relative './labor'
# require 'state_machine'

# module HashStatus
# 	extend ActiveSupport::Concern

# 	DEFAULT_STATUS = 'created'.freeze
# 	AVAILABLE_STATUSES = %w[created pending analyzing running success failed canceled skipped].freeze
# 	STARTED_STATUSES = %w[running success analyzing failed skipped].freeze
# 	ACTIVE_STATUSES = %w[analyzing pending running].freeze
# 	COMPLETED_STATUSES = %w[success failed canceled skipped].freeze
# 	STATUSES_ENUM = { created: 0, pending: 1, running: 2, success: 3,
#                     failed: 4, canceled: 5, skipped: 6, manual: 7 }.freeze

#   UnknownStatusError = Class.new(StandardError)

#   included do
#     validates :status, inclusion: { in: AVAILABLE_STATUSES }

#     state_machine :status, initial: :created do
#       state :created, value: 'created'
#       state :analyzing, value: 'analyzing'
#       state :pending, value: 'pending'
#       state :running, value: 'running'
#       state :failed, value: 'failed'
#       state :success, value: 'success'
#       state :canceled, value: 'canceled'
#       state :skipped, value: 'skipped'
#     end
#   end

#   def started?
#     STARTED_STATUSES.include?(status)# && started_at
#   end

#   def active?
#     ACTIVE_STATUSES.include?(status)
#   end

#   def complete?
#     COMPLETED_STATUSES.include?(status)
#   end

# end
# require_relative './deploy_service/process_pod_deploy_service'
# require_relative './deploy_service/prepare_main_deploy_service'
# require_relative './deploy_service/prepare_pod_deploy_service'
# require_relative './deploy_service/auto_merge_pod_deploy_service'


# include Labor

# class Deploy
# 	attr_accessor :failure_reason
# 	attr_accessor :started_at
# 	attr_accessor :finished_at
# 	attr_accessor :repo_url
# 	attr_accessor :ref

# 	state_machine :status, initial: :created do 
# 		event :analyze do
#       transition created: :analyzing
#     end

# 		event :deploy do 
# 			transition pending: :deploying
# 		end

# 		event :success do 
# 			transition deploying: :success
# 		end

# 		event :skip do 
# 			transition analyzing: :skipped
# 		end

# 		event :enqueue do  
# 			transition [:created, :skipped, :canceled, :failed, :success] => :analyzing
# 		end

# 	  event :drop do
#       transition [:created, :analyzing, :pending, :deploying] => :failed
#     end

# 		event :cancel do
#       transition [:created, :analyzing, :pending, :deploying] => :canceled
#     end


#     before_transition [:created, :analyzing, :pending] => :running do |deploy|
#       deply.started_at = Time.now
#     end

#     before_transition any => [:success, :failed, :canceled] do |deploy|
#       deploy.finished_at = Time.now
#     end

#     before_transition any => :failed do |deploy, transition|
#     	failure_reason = transition.args.first
#     	deploy.failure_reason = failure_reason
#     end

#     after_transition do |deploy, transition|
#     	next if transition.loopback?

#     	# puts '========================'
#     	# p status
#     	# p transition.loopback?
#     	# puts '========================'
#     end
# 	end
# end

# class MainDeploy < Deploy 

# 	attr_accessor :pod_deploys
# 	attr_accessor :grouped_pods
# 	attr_accessor :task_lock

# 	attr_accessor :pods_access_lock
	
# 	def process
# 		Labor::ProcessMainDeployService.new(self).execute
# 	end

# 	def prepare
# 		Labor::PrepareMainDeployService.new(self).execute
# 	end

# 	def create
# 		Labor::CreateMainDeployService.new(self).execute
# 	end

# 	def pod_deploys
# 		@pod_deploys ||= []
# 	end
# end

# class PodDeploy < Deploy 
# 	attr_accessor :pod
# 	attr_accessor :reviewed
# 	attr_accessor :merge_requests 

# 	def prepare
# 		Labor::PreparePodDeployService.new(self).execute
# 	end

# 	def process
# 		Labor::ProcessPodDeployService.new(self).execute
# 	end

# 	def repo_url
# 		pod.dependency.external_source[:git] || pod.spec.source[:git] 
# 	end

# 	def ref 
# 		pod.dependency.external_source[:branch] || 'master'
# 	end

# 	def merge_requests
# 		@merge_requests ||= []
# 	end
# end

# project = gitlab.project('git@git.2dfire-inc.com:qingmu/PodE.git')
# # p project
# data_source = RemoteDataSource.new(project.id, 'release/0.0.1')
# sorter = ExternalPodSorter.new(data_source)
# p sorter.sort
# pod = sorter.grouped_pods.flatten.find { |pod| pod.name == 'PodA' }


# deploy = MainDeploy.new
# deploy.repo_url = 'git@git.2dfire-inc.com:qingmu/PodE.git'
# deploy.ref = 'release/0.0.1'
# deploy.pods_access_lock = Mutex.new
# deploy.create

# deploy.pod_deploys.select { |d| d.repo_url == 'git@git.2dfire-inc.com:qingmu/PodD.git' }.each do |d|
# 	AutoMergePodDeployService.new(d).execute
# end

# p gitlab.merge_requests(2444, '6')

# sleep(2)
# deploy = PodDeploy.new
# deploy.pod = pod
# deploy.process

# p deploy.failure_reason
# p deploy.status
# PodDeploy.

# service = Labor::ProcessPodDeployService.new()
# require 'sinatra'

# gitlab = Labor::GitLab.gitlab
# pr = gitlab.project('git@git.2dfire-inc.com:qingmu/PodA.git')


# p gitlab.create_pipeline(pr.id, 'release/0.2.1')
# mr = gitlab.create_merge_request(pr.id, 'test', '青木', {source_branch: 'release/0.2.1',
# 				target_branch: 'master'})
# p gitlab.add_project_hook(pr.id, 'http://192.168.1.127:8080')

# ruby myapp.rb [-h] [-x] [-q] [-e ENVIRONMENT] [-p PORT] [-o HOST] [-s HANDLER]
# post '/' do 
# 	p req
# 	p res
#   'Hello world!'
# end

# 给所有需要发布的组件同时提交 mr 

# MR 时执行的 pipeline 依然受组件间依赖关系影响
# mr的 pipeline 会随着 commit 更改而更改
# MR 处理过程先不管了，只要考虑 MR 合并成功后的处理步骤即可
# 
# MR 处理过程
# 1、提交所有 mr 后，循环获取 mr 详情中的 pl id (这里实际获取不到啊！)
# 2、使用 cancel_pipeline 取消所有 pl
# 3、遍历可以发布的 pod，使用 retry_pipeline 重启 pl
# 4、pl 执行成功后，mr 被 accept
# 5、有组件发布成功后，重新执行 3 步骤

# merge when pipeline succeeds 只有在有 pipeline 的情况下才会成功
# 以上 MR 处理过程走不通，转为以下处理过程

# 或者
# 1、提交 mr 后，取消 mr 对应分支的 pl
# 2、负责人 review 完成后，在发布网页对应组件输入 review 完成
# 3、后台计算当前组件是否符合发布标准，符合即触发 mr 对应的 pipeline
# 4、没有 pipeline 直接合并，有则设置 pipeline 执行后自动 accept mr 
# 5、根据返回的错误，给负责人发布合并冲突消息

# create_pipeline 和 run_trigger 都能绕过 [ci skip]

# 1.1、取消对应合并分支的最新 pl 

# cancel_pipeline(project, id) 取消 pl
# retry_pipeline(project, id) 重试 pl
# create_pipeline(project, ref) 创建 pl
# 

# gitlab = Labor::GitLab.gitlab
# pr = gitlab.project('git@git.2dfire-inc.com:qingmu/PodA.git')
# mr = gitlab.create_merge_request(pr.id, 'test', '青木', {source_branch: 'release/0.2.1',
# 				target_branch: 'master'})
# p mr.web_url
# changes_count

# CD 处理过程
# 1、合并到 master 后，创建 tag
# 2、创建此 tag 的 pl
# 3、监听 pl 状态，完成后执行 MR 处理过程的 3 步骤


# dep = Deploy.new
# dep.analyze
# dep.status
# dep.drop('1212')
# p dep.status

# dep.enqueue
# dep.status

# p dep.can_enqueue?


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

# pr = gitlab.project('git@git.2dfire-inc.com:ios/TDFMGameCenter.git')
# gitlab_ci_yaml = Labor::RemoteFile::GitLabCIYaml.new(pr.id)
# p gitlab_ci_yaml.has_deploy_jobs?
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
# include Labor

# gitlab = Labor::GitLab.gitlab
# pr = gitlab.project('git@git.2dfire-inc.com:qingmu/PodE.git')

# project_id = pr.id 
# ref = 'master'
# refer_version = '1.3.0'

# rf = SpecificationRemoteFile.new(pr.id, ref)
# p rf.modify_version(refer_version)
# p file


# p sorter.grouped_pods






# p gitlab.user_search('青木').first
# .each do |group|
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
