class ReplaceGroupingsGroupIdWithClassificationId < ActiveRecord::Migration
  def up
    remove_column :groupings, :group_id
    add_column :groupings, :classification_id, :integer
  end

  def down
  end
end
