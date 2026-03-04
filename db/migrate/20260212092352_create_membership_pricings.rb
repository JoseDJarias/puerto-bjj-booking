class CreateMembershipPricings < ActiveRecord::Migration[8.1]
  def change
    create_table :membership_pricings do |t|
      t.references :membership_package, null: false, foreign_key: true
      t.references :membership_plan, null: false, foreign_key: true
      
      t.decimal :price, precision: 10, scale: 2, default: 0

      t.timestamps
    end

    add_index :membership_pricings, [:membership_package_id, :membership_plan_id], unique: true, name: 'idx_pricing_on_package_and_plan'
  end
end
