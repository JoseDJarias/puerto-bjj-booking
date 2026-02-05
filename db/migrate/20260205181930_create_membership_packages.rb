class CreateMembershipPackages < ActiveRecord::Migration[8.1]
  def change
    create_table :membership_packages do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price_modifier, precision: 10, scale: 2, default: 0
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    
    add_index :membership_packages, :active
  end
end
