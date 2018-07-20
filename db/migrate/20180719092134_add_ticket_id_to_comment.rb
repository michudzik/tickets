class AddTicketIdToComment < ActiveRecord::Migration[5.2]
  def change
  	add_column :comments, :ticket_id, :integer, index: true
  end
end
