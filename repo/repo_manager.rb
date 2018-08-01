require_relative './repo'
require_relative './repo_cache'

module Labor
	class Repo
		class Manager
			attr_reader :main_cache

			MAIN_CACHE_DIRECTORY = 'main-cache'.freeze

			class << self
				def instance
					@mananger ||= Manager.new
				end
			end

			def initialize
				@main_cache = Cache.new(MAIN_CACHE_DIRECTORY)
			end
		end
	end
end