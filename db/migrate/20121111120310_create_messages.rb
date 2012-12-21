class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :key
      t.text :string
      t.integer :language_id
      t.string :type
      t.integer :user_id

      t.timestamps
    end
    
    add_index :messages, :key, :unique => true
  end
end
