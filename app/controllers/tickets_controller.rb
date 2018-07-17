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
        @ticket = Ticket.new(ticket_params)
        if @ticket.save
            redirect_to tickets_path, notice: 'New ticket has been reported'
        else
            render :new
        end
    end

    # def close
    #     @ticket = Ticket.find(params[:id])
    # end

    private

    def ticket_params
        params.require(:ticket).permit(:title, :note, :status, :user)
    end
end