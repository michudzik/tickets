class AddIndexOnUserIdAndTicketIdToComments < ActiveRecord::Migration[5.2]
  def change
    change_table :comments do |t|
      t.index :user_id
      t.index :ticket_id
    end
  end
end
