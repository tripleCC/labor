require 'sidekiq'
require 'active_job'
require_relative '../config'
require_relative '../logger'

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{Labor.config.redis_host}:#{Labor.config.redis_port}/#{Labor.config.redis_db}", password: Labor.config.redis_password }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{Labor.config.redis_host}:#{Labor.config.redis_port}/#{Labor.config.redis_db}", password: Labor.config.redis_password }
end

ActiveJob::Base.queue_adapter = :sidekiq

Sidekiq.logger = Labor::Logger.logger