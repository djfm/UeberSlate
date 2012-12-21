class AddAnyLanguageToRoleWhiteLists < ActiveRecord::Migration
  def change
    add_column :role_white_lists, :any_language, :boolean
  end
end
