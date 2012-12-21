class ChangeClassificationsIndex < ActiveRecord::Migration
  def up
    remove_index :classifications, [:pack_id, :group, :category]
    add_index :classifications, [:pack_id, :category, :group], :unique => false
  end

  def down
  end
end
