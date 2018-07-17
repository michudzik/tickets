class DestroyRole < ActiveRecord::Migration[5.2]
  def change
    drop_table :roles
  end
end