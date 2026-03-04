class RemoveUniqueIndexFromDropInTickets < ActiveRecord::Migration[8.1]
  def change
    remove_index :drop_in_tickets, [:user_id, :membership_package_id]

    add_index :drop_in_tickets, [:user_id, :membership_package_id]
  end
end
