Rails.application.reloader.to_prepare do
  ActiveSupport.on_load(:solid_cache_record) do
    
    connects_to database: { writing: :cache, reading: :cache }
  end
end