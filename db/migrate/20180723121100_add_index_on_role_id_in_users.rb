class AddIndexOnRoleIdInUsers < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :role_id
  end
end
