class AddControllerToRoleWhiteLists < ActiveRecord::Migration
  def change
    add_column :role_white_lists, :controller, :string
  end
end
