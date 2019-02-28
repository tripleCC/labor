require 'sidekiq'
require 'active_job'
require_relative '../config'
require_relative '../logger'

config_hash = { url: "redis://#{Labor.config.redis_host}:#{Labor.config.redis_port}/#{Labor.config.redis_db}" }
config_hash[:password] = Labor.config.redis_password if Labor.config.redis_password

Sidekiq.configure_server do |config|
  config.redis = config_hash
end

Sidekiq.configure_client do |config|
  config.redis = config_hash
end

ActiveJob::Base.queue_adapter = :sidekiq

Sidekiq.logger = Labor::Logger.logger