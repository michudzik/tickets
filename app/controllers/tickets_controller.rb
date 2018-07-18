class TicketsController < ApplicationController
    def index
        @tickets = Ticket.all
    end

    def show
        @ticket = Ticket.find(params[:id])
    end

    def new
        @ticket = Ticket.new
    end

    def create
        @user = User.find(params[:user_id])
        @ticket = Ticket.new(ticket_params)
        if @ticket.save
            format.html { redirect_to request.referrer, notice: 'New ticket has been reported' }
        else
            format.html { redirect_to request.referrer, alert: 'There was an error, try create new ticket again' }
            render :new
        end
    end

    # def close
    #     @ticket = Ticket.find(params[:id])
    # end

    private

    def ticket_params
        params.require(:ticket).permit(:title, :note, :status, :user_id, :ticket_id)
    end
end