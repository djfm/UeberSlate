class ChangeCurrentTranslationsPrimaryKeyStuff < ActiveRecord::Migration
  def up
    remove_column :current_translations, :key
    add_column :current_translations, :message_id, :integer
    add_index :current_translations, [:pack_id, :message_id, :language_id], :unique => true, :name => 'most_fields'
  end

  def down
  end
end
