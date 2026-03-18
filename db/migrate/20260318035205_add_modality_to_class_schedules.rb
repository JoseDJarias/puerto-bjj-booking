class AddModalityToClassSchedules < ActiveRecord::Migration[8.1]
  def change
    add_column :class_schedules, :modality, :integer
  end
end
