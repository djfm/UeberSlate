class CreateStorages < ActiveRecord::Migration
  def change
    create_table :storages do |t|
      t.integer :pack_id
      t.integer :message_id
      t.string :storage_method
      t.string :storage_path
      t.string :storage_category
      t.string :storage_custom

      t.timestamps
    end
  end
end
