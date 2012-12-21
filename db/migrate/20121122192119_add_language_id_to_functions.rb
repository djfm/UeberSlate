class AddLanguageIdToFunctions < ActiveRecord::Migration
  def change
    add_column :functions, :language_id, :integer
  end
end
