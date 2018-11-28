module Roles
  class List < ApplicationTransaction
    try :extract_values, catch: ActiveRecord::ActiveRecordError
    map :format_values

    private

    def extract_values
      ::Role.all.pluck(:name, :id)
    end

    def format_values(roles)
      roles.map { |role| [role[0].humanize, role[1]] }
    end
  end
end
