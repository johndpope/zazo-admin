require File.expand_path('../../../config/environment', __FILE__)
require 'rspec/rails'

reports_dir = ENV['WERCKER_REPORT_ARTIFACTS_DIR'] || File.expand_path('../../../tmp', __FILE__)

if ENV.key?('coverage') || ENV.key?('CI')
  require 'simplecov'
  SimpleCov.coverage_dir File.join(reports_dir, 'coverage')
  SimpleCov.start :rails
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.order = :random
  Kernel.srand config.seed

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  if ENV.key?('CI')
    config.add_formatter :html, File.join(reports_dir, 'rspec', 'rspec.html')
  end
end

Dir[Rails.root.join('shared/spec/support/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/support/**/*.rb')].each        { |f| require f }
