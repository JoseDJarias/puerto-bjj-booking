class AddAmountPaidToMemberships < ActiveRecord::Migration[8.1]
  def change
    add_column :memberships, :amount_paid, :decimal, precision: 10, scale: 2
  end
end
