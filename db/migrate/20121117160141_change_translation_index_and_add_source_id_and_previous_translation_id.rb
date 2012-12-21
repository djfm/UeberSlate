class ChangeTranslationIndexAndAddSourceIdAndPreviousTranslationId < ActiveRecord::Migration
  def up
    remove_index :translations, :name => "all_fields"
    add_column :translations, :source_id, :integer
    add_column :translations, :previous_translation_id, :integer
    add_index :translations, [:source_id, :language_id, :key, :reviewer_id, :user_id, :string], :name => "all_fields"
  end

  def down
  end
end
