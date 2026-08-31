class CreateGroupMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :group_memberships do |t|
      t.references :group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
