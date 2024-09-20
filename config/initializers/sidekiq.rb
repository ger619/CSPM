# config/initializers/sidekiq.rb

Sidekiq.configure_server do |config|
  config.redis = { url: Rails.env.production? ? 'redis://default:your_password@172.17.20.11:6379/0' : 'redis://localhost:6379/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.env.production? ? 'redis://default:your_password@172.17.20.11:6379/0' : 'redis://localhost:6379/0' }
end
