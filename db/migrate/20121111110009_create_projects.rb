class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :version
      t.text :comment
      t.integer :user_id

      t.timestamps
    end
  end
end
