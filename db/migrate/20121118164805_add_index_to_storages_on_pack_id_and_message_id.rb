class AddIndexToStoragesOnPackIdAndMessageId < ActiveRecord::Migration
  def change
    add_index :storages, [:pack_id, :message_id], :unique => true
  end
end
