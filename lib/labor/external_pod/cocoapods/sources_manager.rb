require 'cocoapods'
require_relative './source'
require_relative '../../config'
require_relative '../../logger'

module Pod
	class Source
		class Manager
			DEFAULT_SOURCE_URL = Labor.config.cocoapods_private_source_url.freeze

			def newest_specs_with_source_name_or_url(name_or_url)
				source = source_with_name_or_url(name_or_url)
				source.newest_specs if source
			end

			def default_source
				source_with_name_or_url(DEFAULT_SOURCE_URL)
			end
		end
	end
end

module Labor
	module Source
		class Updater
			extend Labor::Logger

			@lock = Mutex.new

			def self.update 
				# 这块应该放到 sidekiq 处理的

				Thread.new do 
					@lock.synchronize do 
						logger.info("update cocoapods private source #{Labor.config.cocoapods_private_source_url}")

						Pod::Config.instance.sources_manager.default_source.update(false)
					end
				end
			end
		end
	end
end