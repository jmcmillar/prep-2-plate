ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

# Rails 8 loads routes lazily; Devise builds its mappings from routes, so load
# them up front for unit tests that create confirmable users.
Rails.application.reload_routes_unless_loaded

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |file| require file }

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Ensure proper fixture loading order
    self.use_transactional_tests = true

    # Add more helper methods to be used by all tests here...
  end
end
