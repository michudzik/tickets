class AddStatusIdToTickets < ActiveRecord::Migration[5.2]
  def change
    change_table :tickets do |t|
      t.remove :status
      t.integer :status_id
      t.index :status_id
    end
  end
end
