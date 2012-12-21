class CreateGroupings < ActiveRecord::Migration
  def change
    create_table :groupings do |t|
      t.integer :group_id
      t.integer :message_id

      t.timestamps
    end
    
    add_index :groupings, [:group_id,:message_id], :unique => true
    
  end
end
