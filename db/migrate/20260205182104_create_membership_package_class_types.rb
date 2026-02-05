class CreateMembershipPackageClassTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :membership_package_class_types do |t|
      t.references :membership_package, null: false, foreign_key: true
      t.references :class_type, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :membership_package_class_types, [:membership_package_id, :class_type_id], 
              unique: true, name: 'index_package_class_types_uniqueness'
  end
end
