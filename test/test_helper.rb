ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

require_relative "support/query_assertions"

module ActiveSupport
  class TestCase
    include QueryAssertions

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    setup do
      Bullet.start_request if defined?(Bullet) && Bullet.enable?
    end

    teardown do
      if defined?(Bullet) && Bullet.enable?
        Bullet.perform_out_of_channel_notifications if Bullet.notification?
        Bullet.end_request
      end
    end

    # The old assert_queries_count has been replaced by assert_queries in QueryAssertions.
  end
end
