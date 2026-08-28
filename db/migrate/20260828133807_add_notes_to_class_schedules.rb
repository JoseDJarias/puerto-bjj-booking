class AddNotesToClassSchedules < ActiveRecord::Migration[8.1]
  def change
    add_column :class_schedules, :notes, :text
  end
end
