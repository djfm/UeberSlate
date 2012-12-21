class CreateRoleWhiteLists < ActiveRecord::Migration
  def change
    create_table :role_white_lists do |t|
      t.integer :role_id
      t.string :action

      t.timestamps
    end
  end
end
