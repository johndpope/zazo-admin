RSpec.configure do |config|
  connections = [:"#{Rails.env}", :"events_db_#{Rails.env}"]

  config.before :suite do
    connections.each { |conn| DatabaseCleaner[:active_record, connection: conn].clean_with :truncation }
  end

  config.before do
    connections.each { |conn| DatabaseCleaner[:active_record, connection: conn].strategy = :truncation }
    DatabaseCleaner.start
  end
end
