class AddGuestInstructorNameToClassSchedules < ActiveRecord::Migration[8.1]
  def change
    add_column :class_schedules, :guest_instructor_name, :string
  end
end