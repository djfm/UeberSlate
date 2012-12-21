class AddIndexToGroupingsClassificationId < ActiveRecord::Migration
  def change
    add_index :groupings, :classification_id, :unique => false
  end
end
