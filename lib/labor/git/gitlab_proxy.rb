require 'gitlab'
require_relative './string_extension'
require_relative './gitlab_api'
require_relative '../errors'

module Labor
	class GitLabProxy
		
		using StringExtension		

		DEFAULT_TRIGGER_DESCRIPTION = 'ci/cd default trigger'.freeze
		DEFAULT_PROJECT_HOOK_OPTIONS = { 
			issues_events: false,
			merge_requests_events: true,
			note_events: false,
			pipeline_events: true,
			wiki_page_events: false,
			job_events: false,
			push_events: false
		}.freeze
		DEFAULT_PROJECT_PUSH_RULE = { 
			deny_delete_tag: true
		}.freeze
		DEFAULT_ACCEPT_MERGE_REQUEST = {
			merge_when_pipeline_succeeds: true
		}.freeze

		attr_reader :client

		def initialize(gitlab_client)
			@client = gitlab_client
		end

		def branch(project_id, ref)
			client.branch(project_id, ref)
		end

		def file_path(project_id, file_name, ref = 'master', depth = 5)
			find_file_path(project_id, ref, depth) do |name|
				file_name == name
			end
		end

		def find_file_path(project_id, ref = 'master', depth = 5, path = '', &matcher)
			tree = client.tree(project_id, {path: path, ref_name: ref})
			target = tree.find do |tr|
				yield tr.name if block_given?
			end
			return File.join(path, target.name) if target
			return nil unless depth > 0
			depth -= 1

			finded_path = nil
			directory_tree = tree.select { |tr| File.extname(tr.name).empty? }
			directory_tree.each do | tr|
				finded_path = find_file_path(project_id, ref, depth, path + tr.name + '/', &matcher)
				break if finded_path
			end
			finded_path
		end

		# get_file 中获取的content是base64编码的，需要使用Base64.decode64解码
		def file_contents(project_id, file_path, ref)
			content = client.file_contents(project_id, file_path, ref)
      content = content.force_encoding("UTF-8") if content
   	end

		def add_push_rule(project_id, push_rule = DEFAULT_PROJECT_PUSH_RULE)
			client.add_push_rule(project_id, push_rule)
		end

		# Gitlab.accept_merge_request 可以自动合并，通过 merge_when_pipeline_succeeds 出发 pipeline 成功后合并
		def create_merge_request(project_id, title, assignee_name, options = {})
			search_options = {
				search: title, 
				state: 'opened', 
				source_branch: options[:source_branch],
				target_branch: options[:target_branch]
			}
			exist_opened_mr = client.merge_requests(project_id, search_options).first
			return exist_opened_mr if exist_opened_mr

			assignee_user = client.user_search(assignee_name).first
			options = options.merge({ assignee_id: assignee_user.id }) if assignee_user
			# remove_source_branch ，是否移除 source 分支
			merge_request = client.create_merge_request(project_id, title, options)
			merge_request 
		end

		def accept_merge_request(project_id, iid, options = DEFAULT_ACCEPT_MERGE_REQUEST)
			client.accept_merge_request(project_id, iid, options)
		end

		# merge_requests_events 触发，合并完成后，可以触发打包功能，可打包标志位置 1
		# pipeline_events 触发，更新网页打包状态
		#
		# webhook 触发失败原因
		# https://gitlab.com/gitlab-org/omnibus-gitlab/issues/3307#note_64245578
		#
		def add_project_hook(project_id, hook_url, options = DEFAULT_PROJECT_HOOK_OPTIONS)
			return if project_hooks(project_id, hook_url, options).any?

			client.add_project_hook(project_id, hook_url, options)
		end

		def project_hooks(project_id, hook_url, options)
			client.project_hooks(project_id).select do |hook|
				if hook.url == hook_url
			 		bool = true
				 	options.each do |k, v|
						unless hook.send(k) == v
							bool = false
							break
						end
					end
					bool
				end
			end
		end

		# 注意 ref 可以是 tag / branch ，如果 tag 和 branch 名字一样，就麻烦了
		def run_trigger(project_id, ref, description = DEFAULT_TRIGGER_DESCRIPTION)
			return if newest_active_pipeline(project_id, ref)

			default_trigger = all_triggers(project_id).find { |trigger| trigger.description == description }
			default_trigger = client.create_trigger(project_id, description) if default_trigger.nil?
			client.run_trigger(project_id, default_trigger.token, ref)
		end

		def newest_active_pipeline(project_id, ref)
			target = client.branches(project_id).find { |b| b.name == ref }
			target = client.tags(project_id).find { |t| t.name == ref } if target.nil?
			return nil if target.nil?
			pipeline = client.pipelines(project_id, { per_page: 10 }).find do |pl|
				%w[pending running created manual].include?(pl.status) &&
				pl.sha == target.commit.id &&
				pl.ref == target.name
			end
			pipeline
		end

		def project(git_url)
			project = client.project_search(git_url.git_name).find do |project| 
          project.ssh_url_to_repo == git_url ||
          project.http_url_to_repo == git_url
      end

      raise Labor::Error::NotFound.new("Can't find project with url #{git_url}") if project.nil?
      project
		end

		def all_branches(project_id)
			fetch_all do |client|
				client.branches(project_id, { per_page: 100 })
			end
		end

		def all_triggers(project_id)
			fetch_all do |client|
				client.triggers(project_id)
			end
		end

		def all_users
			fetch_all do |client|
				client.users({per_page: 100})
			end
		end

		def fetch_all(&block)
			return [] unless block_given?

			all_items = []
      items = yield client

      if items.respond_to?(:has_next_page?) &&
  			 items.respond_to?(:next_page)
	      loop do
	        all_items += items
	        break unless items.has_next_page?
	        items = items.next_page
	      end 
			end
      all_items
		end

		def respond_to_missing?(method, include_private = false)
			client.respond_to?(method) || super
		end

		def method_missing(method, *args, &block)
			super unless client.respond_to?(method)
			client.send(method, *args)
		end
	end
end