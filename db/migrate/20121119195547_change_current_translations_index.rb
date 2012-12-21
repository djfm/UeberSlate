class ChangeCurrentTranslationsIndex < ActiveRecord::Migration
  def up
    remove_index :current_translations, :name => "most_fields"
    add_index :current_translations, [:pack_id, :message_id, :language_id, :translation_id], :unique => true, :name => 'all_fields_current_translations'
  end

  def down
  end
end
