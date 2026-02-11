class CreateClassSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :class_schedules do |t|
      # Relationships
      t.references :class_type, null: false, foreign_key: true
      t.references :instructor, null: false, foreign_key: { to_table: :users }

      # Temporary data
      t.datetime :starts_at, null: false
      t.integer :duration_minutes, default: 60, null: false
      t.integer :capacity, default: 20, null: false # Cupo del tatami

      # Optional: To cancel a specific class without deleting it (e.g.: holiday)
      t.boolean :cancelled, default: false, null: false

      t.timestamps
    end
    # faster queries for class schedules by start time
    add_index :class_schedules, :starts_at
  end
end
