class CreateDropInTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :drop_in_tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :membership_package, null: false, foreign_key: true
      t.references :booking, foreign_key: true
      t.integer :status, default: 0, null: false
      t.decimal :price_paid, precision: 10, scale: 2
      t.datetime :used_at
      t.timestamps
    end

    add_index :drop_in_tickets, [:user_id, :membership_package_id], unique: true
  end
end
