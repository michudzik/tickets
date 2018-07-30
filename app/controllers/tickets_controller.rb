class TicketsController < ApplicationController
  def index
    redirect_to user_dashboard_path, alert: 'Forbidden access' and return if current_user.user?
    @tickets = Ticket.find_related_tickets(current_user).paginate(page: params[:page], per_page: params[:number])
  end

  def show
    @ticket = Ticket.find(params[:id])
    redirect_to user_dashboard_path, alert: 'Forbidden access' and return unless @ticket.related_to_ticket?(current_user)
    @comment = Comment.new(ticket_id: @ticket.id)
    @status = @ticket.status.name.humanize
  end

  def new
    @ticket = current_user.tickets.build
    @departments = Department.all.pluck(:name, :id)
  end

  def create
    @ticket = current_user.tickets.build(ticket_params)
    if @ticket.save
      redirect_to user_dashboard_path, notice: 'New ticket has been reported'
    else
      @departments = Department.all.pluck(:name, :id)
      render :new
    end
  end

  def update
    @ticket = Ticket.find(params[:id])
    status_closed = Status.find_by(name: 'closed')
    @ticket.update(status_id: status_closed.id)
    redirect_to user_dashboard_path, notice: 'Ticket closed'
  end

  private

  def ticket_params
    params.require(:ticket).permit(:title, :note, :status, :department_id, uploads: [])
  end
end
