class AddUserIdToRole < ActiveRecord::Migration[5.2]
  def change
  	add_column :roles, :user_id, :integer, index: true
  end
end
