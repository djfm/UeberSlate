class AddArchivePathToModulePacks < ActiveRecord::Migration
  def change
    add_column :module_packs, :archive_path, :string
  end
end
