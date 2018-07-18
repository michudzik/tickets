class CreateTicket < ActiveRecord::Migration[5.2]
  def change
    create_table :tickets do |t|
      t.string :title
      t.text :note
      t.string :user
      t.string :department
      t.string :status
      t.timestamps
    end
  end
end