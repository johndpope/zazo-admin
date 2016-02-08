require 'rollbar/rails'

Rollbar.configure do |config|
  config.access_token = Figaro.env.rollbar_access_token

  if Rails.env.in? %w(development test)
    config.enabled = false
  end
end
