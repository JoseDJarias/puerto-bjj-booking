class RefactorDropInTicketsToUniversal < ActiveRecord::Migration[8.1]
  def change
    remove_reference :drop_in_tickets, :membership_package, foreign_key: true
    remove_index :drop_in_tickets, name: "index_drop_in_tickets_on_user_id_and_membership_package_id"
    
    add_index :drop_in_tickets, :user_id unless index_exists?(:drop_in_tickets, :user_id)
  end
end