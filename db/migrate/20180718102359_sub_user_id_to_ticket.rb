class SubUserIdToTicket < ActiveRecord::Migration[5.2]
  def change
    remove_column :tickets, :user, :string
  end
end
