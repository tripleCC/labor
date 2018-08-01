require 'cocoapods'

module Labor
	class Config 
		def default_source
			Pod::Config.instance.sources_manager.default_source
		end

		def newest_version(name)
			source.update(false)
		  newest_version = default_source.versions(name).sort.last
		  newest_version
		end

		def self.instance
      @instance ||= new
	  end

	  module Mixin
      def config
        Config.instance
      end
    end
	end
end