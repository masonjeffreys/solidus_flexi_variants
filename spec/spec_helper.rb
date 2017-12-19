require 'simplecov'
SimpleCov.start 'rails'

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'rspec/rails'
require 'database_cleaner'
require 'factory_bot'
require 'ffaker'
require 'shoulda-matchers'
require 'pry'

require 'spree/testing_support/preferences'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/capybara_ext'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/factories'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/order_walkthrough'

require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'capybara/poltergeist'
Capybara.register_driver(:poltergeist) do |app|
  Capybara::Poltergeist::Driver.new app, {
    phantomjs_options: %w[--ssl-protocol=any --ignore-ssl-errors=true --load-images=false],
    timeout: 90
  }
end
Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = 10

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }
Dir[File.join(File.dirname(__FILE__), 'factories/*.rb')].each { |f| require f }



RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::ControllerRequests, type: :controller

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.infer_spec_type_from_file_location!
  config.mock_with :rspec
  config.order = "random"
  config.color = true
  config.use_transactional_fixtures = false
  config.fail_fast = ENV['FAIL_FAST'] || false

  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end
