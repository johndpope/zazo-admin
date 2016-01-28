require 'rails'

namespace :db do
  namespace :multiple do
    namespace :schema do
      DATABASES_CONFIG = [
        { connection: Rails.env, file: 'shared/db/schema_users_db.rb' },
        { connection: "events_db_#{Rails.env}", file: 'shared/db/schema_events_db.rb' }
      ]

      task :load => :environment do
        DATABASES_CONFIG.each do |config|
          ActiveRecord::Tasks::DatabaseTasks.load_schema_current :ruby, Rails.root.join(config[:file]), config[:connection]
        end
      end

      task :dump => :environment do
        DATABASES_CONFIG.each do |config|
          ActiveRecord::Base.establish_connection config[:connection].to_sym
          File.open Rails.root.join(config[:file]), 'w:utf-8' do |file|
            ActiveRecord::SchemaDumper.dump ActiveRecord::Base.connection, file
          end
        end
      end
    end
  end
end
