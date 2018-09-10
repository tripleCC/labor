require 'sidekiq'
require_relative '../config'

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{Labor.config.host}:#{Labor.config.redis_port}/#{Labor.config.redis_db}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{Labor.config.host}:#{Labor.config.redis_port}/#{Labor.config.redis_db}" }
end