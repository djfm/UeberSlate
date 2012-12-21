class CreateTranslations < ActiveRecord::Migration
  def change
    create_table :translations do |t|
      t.string :key
      t.integer :language_id
      t.text :string
      t.integer :user_id
      t.integer :reviewer_id

      t.timestamps
    end
  end
end
