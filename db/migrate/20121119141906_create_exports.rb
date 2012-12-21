class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.integer :pack_id
      t.integer :language_id
      t.string :url

      t.timestamps
    end
  end
end
