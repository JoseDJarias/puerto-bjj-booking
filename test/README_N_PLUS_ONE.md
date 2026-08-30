# N+1 Prevention & Eager Loading Guide

To ensure performance and strictly prevent N+1 queries, we enforce the following rules and testing strategies:

## 1. Controller Eager Loading (The Golden Rule)
Whenever a controller action renders a view that iterates over a collection (e.g., `@patients.each`), **you MUST use `.includes`** in the controller to preload any associations accessed inside that loop.

**Bad:**
```ruby
def index
  @patients = Patient.all
end
# In view: <% @patients.each do |p| %><%= p.appointments.count %><% end %>
```

**Good:**
```ruby
def index
  @patients = Patient.includes(:appointments).all
end
# In view: <% @patients.each do |p| %><%= p.appointments.size %><% end %>
```

## 2. In-Memory vs SQL Methods
When an association is eager-loaded, avoid SQL-triggering methods:
- Use `assoc.size` instead of `assoc.count`
- Use `assoc.any?` instead of `assoc.exists?`
- Use `assoc.to_a.count(&:condition?)` instead of `assoc.where(condition).count`

## 3. Testing with `assert_queries`
Every controller integration test that renders collections MUST verify clean query execution without N+1 query loops. We use a custom test helper in `test/support/query_assertions.rb`.

```ruby
test "should get index without N+1 queries" do
  sign_in_as(@user)
  
  assert_queries(5) do # Specify the expected number of queries
    get patients_path
  end
  
  assert_response :success
end
```

## 4. Bullet Integration
`Bullet` is enabled by default in the `test` environment (`config/environments/test.rb`). If you introduce an N+1 query in a controller, Bullet will immediately intercept it and raise a `Bullet::NotificationError`, causing your tests to fail.

## 5. Auditing
You can run `ruby script/eager_loading_audit.rb` to scan `app/views/**/*.erb` and generate a report of all collection loops and their accessed associations. Check `tmp/eager_loading_report.md` for the results.
