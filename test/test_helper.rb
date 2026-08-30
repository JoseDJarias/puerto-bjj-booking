ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
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

    # Custom helper to assert exact or max SQL query count during a block execution
    def assert_queries_count(expected_or_range, message = nil, &block)
      queries = []
      subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, _start, _finish, _id, payload|
        sql = payload[:sql].to_s.strip
        unless payload[:name] == "SCHEMA" || sql =~ /\A(BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE SAVEPOINT)\b/i
          queries << sql
        end
      end

      yield

      if expected_or_range.is_a?(Range)
        assert expected_or_range.cover?(queries.size), message || "Expected query count in #{expected_or_range}, got #{queries.size}:\n#{queries.join("\n")}"
      else
        assert_equal expected_or_range, queries.size, message || "Expected #{expected_or_range} queries, got #{queries.size}:\n#{queries.join("\n")}"
      end
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
    end
  end
end
