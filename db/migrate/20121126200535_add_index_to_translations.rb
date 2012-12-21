class AddIndexToTranslations < ActiveRecord::Migration
  def change
	add_index :translations, :user_id, :unique => false
	add_index :translations, :reviewer_id, :unique => false
  end
end
