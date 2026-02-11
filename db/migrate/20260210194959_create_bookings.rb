class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :class_schedule, null: false, foreign_key: true
      
      # Save who made the last change (User ID).
      # Puede ser nulo al principio o si el sistema lo hace automático, 
      # but ideally it will always have the ID of the User or the Admin.
      t.references :changed_by, null: true, foreign_key: { to_table: :users }

      # 0=Confirmed, 1=Cancelled_by_User, 2=Cancelled_by_Admin, 3=Attended, 4=No_Show
      t.integer :status, default: 0, null: false 
      
      # Starts at 1 because the creation counts as the first attempt.
      t.integer :submission_count, default: 1, null: false 

      t.timestamps
    end

    # This composite index ensures that there are no duplicates.
    # A user can only have ONE row per class. 
    # If they want to book again, we reuse that row changing the status.
    add_index :bookings, [:user_id, :class_schedule_id], unique: true
  end
end