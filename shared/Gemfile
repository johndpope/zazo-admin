gem 'rails'
gem 'pg'
gem 'mysql2'

gem 'rollbar'
gem 'settingslogic'
gem 'figaro', github: 'asux/figaro', branch: 'feature/eb-set-command'

gem 'aasm'
gem 'phonelib'
gem 'global_phone'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard'
  gem 'guard-bundler', require: false
  gem 'guard-pow', require: false
  gem 'guard-rspec', require: false
  gem 'guard-zeus'
  gem 'terminal-notifier-guard'
  gem 'rack-mini-profiler'
  gem 'bullet'
end

group :development, :test do
  gem 'pry-rescue'
  gem 'pry-remote'
  gem 'pry-byebug', '= 1.3.3'
  gem 'rspec-rails'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'shoulda-matchers', '~> 3.0'
  gem 'simplecov', require: false
  gem 'timecop'
end
