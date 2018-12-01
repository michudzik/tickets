module Departments
  class List < ApplicationTransaction
    try :extract_values, catch: ActiveRecord::ActiveRecordError

    private

    def extract_values
      ::Department.all.pluck(:name, :id)
    end
  end
end
