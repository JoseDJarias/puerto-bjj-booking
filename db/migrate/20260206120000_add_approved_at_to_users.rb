# frozen_string_literal: true

class AddApprovedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :approved_at, :datetime
    add_index :users, :approved_at
  end
end
