class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :membership_plan, null: false, foreign_key: true
      t.references :membership_package, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
    
    add_index :memberships, :status
    add_index :memberships, [:user_id, :status]
    add_index :memberships, :end_date
  end
end
