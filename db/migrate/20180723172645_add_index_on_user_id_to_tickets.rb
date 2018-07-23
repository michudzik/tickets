class AddIndexOnUserIdToTickets < ActiveRecord::Migration[5.2]
  def change
    change_table :tickets do |t|
      t.index :user_id
    end
  end
end
