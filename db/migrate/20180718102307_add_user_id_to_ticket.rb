class AddUserIdToTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :user_id, :integer, index: true
  end
end
