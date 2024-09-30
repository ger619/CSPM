# frozen_string_literal: true


Sentry.init do |config|
  config.dsn = 'https://c8d22bdb73eb46303a666a15221e86ea@o4507601057808384.ingest.de.sentry.io/4508040944615504'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for tracing.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    true
  end
  # Set profiles_sample_rate to profile 100%
  # of sampled transactions.
  # We recommend adjusting this value in production.
  config.profiles_sample_rate = 1.0
end