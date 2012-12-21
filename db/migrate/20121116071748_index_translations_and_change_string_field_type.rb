class IndexTranslationsAndChangeStringFieldType < ActiveRecord::Migration
  def up
    change_column :translations, :string, :text
    add_index :translations, [:language_id, :key, :reviewer_id, :user_id, :string], :name => "all_fields", :unique => true
  end

  def down
  end
end
