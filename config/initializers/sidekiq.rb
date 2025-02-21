require 'sidekiq-cron'

Sidekiq::Cron::Job.create(
  name: 'SLA Breach Checker - every 30 minutes',
  cron: '*/30 * * * *', # Runs every 30 minutes
  class: 'SlaBreachCheckerJob'
)

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://:your_password@localhost:6379/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://:your_password@localhost:6379/0' }
end

