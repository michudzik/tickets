module Tickets
  class Show < ApplicationTransaction
    try :assign_object, catch: ActiveRecord::RecordNotFound
    check :related_to_ticket

    private

    def assign_object(id)
      ::Ticket.find(id)
    end

    def related_to_ticket(ticket)
      ticket.related_to_ticket?(current_user)
    end
  end
end
