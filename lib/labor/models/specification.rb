require 'active_record'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative '../external_pod/sorter'
require_relative '../models/project'
require_relative '../remote_file'
require_relative '../config'

module Labor
  class Specification < ActiveRecord::Base
  	belongs_to :project
  	self.per_page = 30

		enum spec_type: { basic: 0, weak_business: 1, business: 2 }  	

		before_save :set_spec_type
		before_save :set_third_party

		scope :newest, -> { order({ name: :asc, version: :desc }).select('distinct on (name) *') }
		scope :without_third_party, -> { where(third_party: false) }

		class << self 
			def update_or_delete_by_webhook_object(object)
				repo_url = object['project']['git_ssh_url']
				project = Project.find_or_create_by_repo_url(repo_url)

				object['commits'].each do |commit|
					removed = commit['removed']
					updated = commit['added'] + commit['modified']

					updated.each do |blob|
						name, version, _ = blob.split('/') 
						remote_spec = Labor::RemoteFile::Specification.new(project.id, 'master', blob)
						create_or_update_specification_by(name, version, remote_spec.file_contents, remote_spec.specification)
					end

					removed.each do |blob| 
						name, version, _ = blob.split('/') 
						remove_specification_by(name, version) 
					end
				end
			end

			def create_or_update_specification_by(name, version, spec_content, specification)
				spec_source = specification.source
				repo_url = spec_source && spec_source[:git]

				spec = Specification.find_or_create_by(name: name, version: version).tap do |spec|
					spec.spec_content = spec_content
					spec.source = spec_source
					spec.authors = specification.authors
					spec.summary = specification.summary
					spec.project = Project.find_or_create_by_repo_url(repo_url) if repo_url
					spec.save
				end
			rescue Labor::Error::NotFound => error
			end

			def remove_specification_by(name, version)
				spec = Specification.find(name: name, version: version)
				spec.destroy
			rescue ActiveRecord::RecordNotFound => error
			end
		end

		private
		def set_spec_type
			matched_type = Specification.spec_types.keys.find { |t| summary&.start_with?(t) }
			self.spec_type = (matched_type || 'business').to_sym
		end

		def set_third_party
			return if source&.empty?

			in_third_party_group = source['git']&.include?(Labor.config.cocoapods_third_party_group)
			# in_internal_server = (source['http'] || source['https'])&.include?('2dfire') 
			self.third_party = !!in_third_party_group #|| !in_internal_server
		end
	end
end