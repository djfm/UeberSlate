class CreateModulePacks < ActiveRecord::Migration
  def change
    create_table :module_packs do |t|
      t.string :module_name
      t.string :project_id
      t.string :pack_id

      t.timestamps
    end
  end
end
