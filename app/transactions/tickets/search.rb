module Tickets
  class Search < ApplicationTransaction
    check :permission
    map :search
    try :filter, catch: ActiveRecord::ActiveRecordError

    private

    def permission
      !current_user.user?
    end

    def search
      Ticket.where('title LIKE ? OR note LIKE ?', "%#{current_params}%", "%#{current_params}%")
    end

    def filter(tickets)
      return tickets.it_department if current_user.it_support?

      return tickets.om_department if current_user.om_support?

      tickets
    end
  end
end
