module Tickets
  class Close < ApplicationTransaction
    try :find_object, catch: ActiveRecord::RecordNotFound
    try :change_status, catch: ActiveRecord::ActiveRecordError

    private

    def find_object(id)
      ::Ticket.find(id)
    end

    def change_status(ticket)
      new_status = ::Status.find_by(name: 'closed')
      ticket.update(status: new_status)
      ticket
    end
  end
end
