class ChangeStatusStatusToStatusName < ActiveRecord::Migration[5.2]
  def change
    change_table :statuses do |t|
      t.rename :status, :name
    end
  end
end
