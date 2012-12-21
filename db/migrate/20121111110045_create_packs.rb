class CreatePacks < ActiveRecord::Migration
  def change
    create_table :packs do |t|
      t.integer :project_id
      t.string :name
      t.text :comment
      t.integer :user_id

      t.timestamps
    end
  end
end
