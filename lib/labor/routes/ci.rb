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
			querys = params.select { |key, value| keys.include?(key) && value.present? }

			newest_ids = Labor::Specification.newest(:id).without_third_party.where(querys)
			all = Labor::Specification.where(id: newest_ids).with_project.order(owner: :desc)
			specifications = all.paginate(page: params[:page], per_page: params[:per_page])
			response = specifications.map do |spec|
				{
					id: spec.id,
					name: spec.name,
					owner: spec.owner,
					team: spec.team,
					pipeline_url: spec.project.pipeline_url,
					web_url: spec.project.web_url,
					master_url: spec.project.master_url,
				}
			end

			per_page = params[:per_page] || Labor::Specification.per_page

			bank = MemberReminder::MemberBank.new

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