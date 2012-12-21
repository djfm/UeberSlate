class CreateCurrentTranslations < ActiveRecord::Migration
  def change
    create_table :current_translations do |t|
      t.integer :pack_id
      t.string  :key
      t.integer :language_id
      t.integer :translation_id

      t.timestamps
    end
    
    add_index :current_translations, [:pack_id, :key, :language_id, :translation_id], :unique => true, :name => "all_fields_current_translations"
    
  end
end
