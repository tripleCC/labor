require 'yaml'
require 'ostruct'

module Labor
	class Config
		def initialize() 
			@config = OpenStruct.new load_config
		end

		def deploy_host 
			@deploy_host ||= begin 
				host = @config.host
				if ['127.0.0.1', 'localhost'].include?(@config.host)
					require 'socket'
					ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
					host = ip.ip_address if ip
				end 
				host
			end
		end

		def webhook_url
			@webhook_url ||= begin
				"http://#{deploy_host}:#{port}/webhook"
			end
		end

		def sidekiq_log_file
			sidekiq_log_file = File.expand_path(@config.sidekiq_log_file)
			unless File.exist?(sidekiq_log_file)
				parent_dir, _separator, _filename = sidekiq_log_file.rpartition('/')
			  FileUtils.mkdir_p(parent_dir)
			  FileUtils.touch(sidekiq_log_file)
			end
			sidekiq_log_file
		end

		private
		def load_config 
			current_path        = File.expand_path(File.dirname(__FILE__))
	    custom_config_file  = File.expand_path("~/.labor/config.yml")
	    default_config_file = File.expand_path("#{current_path}/../../config/config.yml")

	    abort 'labor config file #{default_config_file} is missing.' unless File.exists?(default_config_file)
	    final_config = YAML.load_file(default_config_file)
	    if File.exists?(custom_config_file)
	      begin
	        custom_config = YAML.load_file(custom_config_file)
	      rescue Psych::SyntaxError => ex
	        puts "解析自定义配置文件失败 #{ex.message}."
	        custom_config = {}
	      end
	      final_config.merge!(custom_config)
	    end

	    final_config
		end

		def respond_to_missing?(method, include_private = false)
			@config.respond_to?(method) || super
		end

		def method_missing(method, *args, &block)
			super unless @config.respond_to?(method)
			@config.send(method, *args)
		end
	end

	def self.config()
		@config ||= Config.new
	end
end