gem 'rails'
gem 'pg'
gem 'mysql2'

gem 'rollbar'
gem 'settingslogic'
gem 'figaro', github: 'asux/figaro', branch: 'feature/eb-set-command'

gem 'aasm'
gem 'phonelib'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-pow', require: false
  gem 'terminal-notifier-guard'
  gem 'bullet'
  gem 'rack-mini-profiler'
end

group :development, :test do
  gem 'pry-rescue'
  gem 'pry-remote'
  gem 'pry-byebug', '= 1.3.3'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :test do
  gem 'database_cleaner'
  gem 'faker'
  gem 'shoulda-matchers', '~> 3.0'
  gem 'simplecov', require: false
  gem 'timecop'
end
