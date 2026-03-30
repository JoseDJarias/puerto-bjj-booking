# config/initializers/solid_cache.rb
Rails.application.reloader.to_prepare do
  ActiveSupport.on_load(:solid_cache_record) do
    self.connects_to database: { writing: :cache, reading: :cache }
  end
end