module Tickets
  class New < ApplicationTransaction
    map :assign_object

    private

    def assign_object(user)
      user.tickets.build
    end
  end
end
