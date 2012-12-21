class CreateClassifications < ActiveRecord::Migration
  def change
    create_table :classifications do |t|
      t.integer :pack_id
      t.string :group
      t.string :category

      t.timestamps
    end
    
    add_index :classifications, [:pack_id, :group, :category], :unique => true
  end
end
