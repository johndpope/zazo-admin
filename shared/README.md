# Zazo Shared

## Usage

Add this line to *Gemfile*:
```
eval_gemfile 'shared/Gemfile'
```

Add this line to *Rakefile*:
```
Dir.glob('shared/tasks/*.rake').each { |r| load r }
```

Add this lines to *application.rb*:
```
config.autoload_paths += %W(#{config.root}/shared/models)
self.paths['config/database'] = 'shared/config/database.yml'
```

Set up ENV-variables in *application.yml*
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
