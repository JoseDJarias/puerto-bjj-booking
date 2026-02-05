class CreateClassTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :class_types do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    
    add_index :class_types, :name, unique: true
    add_index :class_types, :active
  end
end
