module Users
  class Show < ApplicationTransaction
    try :extract_tickets, catch: ActiveRecord::ActiveRecordError
    map :paginate

    private

    def extract_tickets
      current_user.tickets
    end

    def paginate(tickets)
      tickets.paginate(page: current_params[:page], per_page: current_params[:number])
    end
  end
end
