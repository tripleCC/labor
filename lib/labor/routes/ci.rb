require 'member_reminder'
require "sinatra/base"
require 'http'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../models/specification'
require_relative '../errors'


module Labor
	class App < Sinatra::Base

		clean_options_get '/ci/status' do 
			keys = [:owner, :team, :name].map(&:to_s)
			querys = params.select { |key, value| keys.include?(key) }

			bank = MemberReminder::MemberBank.new

			all = Labor::Specification.with_project.newest.without_third_party.where(querys)
			specifications = all.paginate(page: params['page'], per_page: params['per_page'])
			response = specifications.map do |spec|
				hash = {
					id: spec.id,
					name: spec.name,
					pipeline_url: spec.project.pipeline_url,
					web_url: spec.project.web_url,
					master_url: spec.project.master_url,
				}

				if spec.authors
					member = bank.member_of_authors(spec.authors) 
					owner = member&.name || spec.authors.keys.first
					hash[:owner] = owner
					hash[:team_name] = member&.team&.name
				end
				hash
			end.compact

			per_page = params[:per_page] || Labor::Specification.per_page

			labor_response response, {
				meta: {
					owners: bank.members.map(&:name),
					teams: bank.teams.map(&:name),
					total_count: all.size,
					per_page: per_page
				}
			}
		end
	end
end