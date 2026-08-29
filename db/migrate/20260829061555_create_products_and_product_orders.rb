class CreateProductsAndProductOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :deposit_percentage, default: 50, null: false
      t.text :notes
      t.string :category
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    add_index :products, :active
    add_index :products, :category

    create_table :product_orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.string :product_name, null: false
      t.decimal :product_price, precision: 10, scale: 2, null: false
      t.decimal :deposit_amount, precision: 10, scale: 2, null: false
      t.text :user_notes
      t.boolean :terms_accepted, default: false, null: false
      t.datetime :terms_accepted_at
      t.text :admin_notes

      t.timestamps
    end
    add_index :product_orders, :status
  end
end
