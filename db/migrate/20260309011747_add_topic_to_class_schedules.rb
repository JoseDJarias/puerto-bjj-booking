class AddTopicToClassSchedules < ActiveRecord::Migration[8.1]
  def change
    add_column :class_schedules, :topic, :string
  end
end
