# Zazo Shared

## Setup

Add this line to *Gemfile*:
```
eval_gemfile 'shared/Gemfile'
```

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

## Usage

Dump existing databases' schemas:
```
rake db:multiple:schema:dump
```

Load databases' schemas:
```
rake db:multiple:schema:load
```
