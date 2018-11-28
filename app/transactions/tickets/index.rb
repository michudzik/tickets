module Tickets
  class Index < ApplicationTransaction
    check :permission
    try :extract_tickets, catch: ActiveRecord::ActiveRecordError
    try :filter, catch: ActiveRecord::ActiveRecordError
    try :sort, catch: ActiveRecord::ActiveRecordError
    map :paginate

    private

    def permission
      !current_user.user?
    end

    def extract_tickets(*_args)
      ::Ticket.find_related_tickets(current_user)
    end

    def filter(tickets)
      tickets.filter_tickets(current_params[:filter_param])
    end

    def sort(tickets)
      tickets.sort_tickets(current_params[:sorted_by])
    end

    def paginate(tickets)
      tickets.paginate(page: current_params[:page], per_page: current_params[:number])
    end
  end
end
