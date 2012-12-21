class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.integer :pack_id
      t.integer :language_id
      t.string :category
      t.integer :total
      t.integer :translated

      t.timestamps
    end
    add_index :statistics, [:pack_id, :language_id, :category], :unique => true
  end
end
