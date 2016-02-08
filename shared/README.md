# Zazo Shared

## Usage

Dump existing databases' schemas:
```
rake db:multiple:schema:dump
```

Load databases' schemas:
```
rake db:multiple:schema:load
```

## Setup

Add this line to *Rakefile*:
```
Dir.glob('shared/lib/tasks/*.rake').each { |r| load r }
```

Add this lines to *config/application.rb*:
```
config.autoload_paths += %W(#{config.root}/shared/app/models)
self.paths['config/database'] = 'shared/config/database.yml'
```

Set up ENV-variables in *config/application.yml*
```
users_db_host:
users_db_name:
users_db_username:
users_db_password:

events_db_host:
events_db_name:
events_db_username:
events_db_password:
```

Create *spec/rails_helper.rb* file with content below:
```
ENV['RAILS_ENV'] ||= 'test'

require_relative '../shared/spec/spec_helper'
```

Add shared gems to *Gemfile*:
```
gem 'rails'
gem 'pg'
gem 'mysql2'

gem 'rollbar'
gem 'settingslogic'
gem 'figaro', github: 'asux/figaro', branch: 'feature/eb-set-command'

gem 'aasm'
gem 'phonelib'
gem 'global_phone'
gem 'enum_handler', github: 'asux/enum_handler'

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
```
