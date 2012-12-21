class AddLastTranslationUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_translation_url, :string
  end
end
