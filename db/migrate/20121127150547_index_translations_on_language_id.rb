class IndexTranslationsOnLanguageId < ActiveRecord::Migration
  def up
	add_index :translations, :language_id, :unique => false
  end

  def down
  end
end
