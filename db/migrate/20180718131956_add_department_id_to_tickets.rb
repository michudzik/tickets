class AddDepartmentIdToTickets < ActiveRecord::Migration[5.2]
  def change
    change_table :tickets do |t|
      t.remove :department, :name
      t.integer :department_id
      t.index :department_id
    end
  end
end
