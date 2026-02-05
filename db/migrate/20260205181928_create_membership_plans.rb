class CreateMembershipPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :membership_plans do |t|
      t.string :name, null: false
      t.integer :duration_months, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    
    add_index :membership_plans, :active
  end
end
