class AddRoleAndStatusToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :integer, default: 0, null: false
    add_column :users, :status, :integer, default: 0, null: false
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    
    add_index :users, :role
    add_index :users, :status
  end
end
