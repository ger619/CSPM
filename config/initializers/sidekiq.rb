Sidekiq.configure_server do |config|
  config.redis = { url: Rails.env.production? ? 'redis://172.17.20.11:6379/0' : 'redis://localhost:6379/0' }
end
