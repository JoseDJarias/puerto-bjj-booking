Rails.application.config.to_prepare do
  module SolidCache
    class Record < ActiveRecord::Base
      establish_connection(:cache)
      def self.with_shard(shard, &block)
        yield
      end
    end
  end
end