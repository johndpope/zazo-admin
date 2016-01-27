RSpec.configure do |config|
  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    [Rails.env, "events_db_#{Rails.env}"].each do |database|
      ActiveRecord::Base.establish_connection database.to_sym
      DatabaseCleaner.clean_with :truncation
    end
  end
end
