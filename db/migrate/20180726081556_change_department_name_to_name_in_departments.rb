class ChangeDepartmentNameToNameInDepartments < ActiveRecord::Migration[5.2]
  def change
    change_table :departments do |t|
      t.rename :department_name, :name
    end
  end
end
