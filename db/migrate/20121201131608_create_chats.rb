class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.integer :user_id
      t.string :name
      t.text :topic

      t.timestamps
    end
  end
end
