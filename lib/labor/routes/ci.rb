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
			bank = MemberReminder::MemberBank.new
			specifications = Labor::Specification.includes(:project).newest.without_third_party
			response = specifications.map do |spec|
				next nil unless spec.project

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

			labor_response response
		end
	end
end