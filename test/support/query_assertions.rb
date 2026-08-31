module QueryAssertions
  def assert_queries(expected_count, &block)
    queries = []
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      sql = event.payload[:sql].to_s.strip
      unless event.payload[:name] == "SCHEMA" || event.payload[:name] == "TRANSACTION" || sql.start_with?("SAVEPOINT") || sql.start_with?("RELEASE SAVEPOINT")
        queries << sql
      end
    end
    yield
    assert_equal expected_count, queries.size, "Expected #{expected_count} queries, but #{queries.size} were executed.\nQueries:\n#{queries.join("\n\n")}"
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  def assert_no_queries(&block)
    assert_queries(0, &block)
  end
end
