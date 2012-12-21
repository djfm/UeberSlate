class AddIsCurrentToPacks < ActiveRecord::Migration
  def change
    add_column :packs, :is_current, :boolean
  end
end
