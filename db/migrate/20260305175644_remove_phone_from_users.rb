class RemovePhoneFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :phone
  end
end
