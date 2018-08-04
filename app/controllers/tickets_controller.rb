class TicketsController < ApplicationController
  def index
    redirect_to user_dashboard_path, alert: 'Forbidden access' and return if current_user.user?
    @tickets = Ticket.find_related_tickets(current_user)
    @tickets = @tickets.filter_tickets(params[:filter_param]) if params[:filter_param]
    @tickets = if params[:sorted_by]
                 @tickets.sort_tickets(params[:sorted_by])
               else
                 @tickets.ordered_by_date
               end
    @tickets = @tickets.paginate(page: params[:page], per_page: params[:number])
  end

  def show
    @ticket = Ticket.find(params[:id])
    unless @ticket.related_to_ticket?(current_user)
      redirect_to(
        user_dashboard_path,
        alert: 'Forbidden access'
      ) and return
    end
    @comment = Comment.new(ticket_id: @ticket.id)
    @comments = @ticket.comments.order(created_at: :asc)
    @status = @ticket.status.name.humanize
  end

  def new
    @ticket = current_user.tickets.build
    @departments = Department.all.pluck(:name, :id)
  end

  def create
    @ticket = current_user.tickets.build(ticket_params)
    if @ticket.save
      @emails = if @ticket.department.name == 'IT'
                  User.joins(:role).where(roles: { name: 'it_support' }).distinct.pluck(:email)
                else
                  User.joins(:role).where(roles: { name: 'om_support' }).distinct.pluck(:email)
                end
      @emails.delete(current_user.email)
      @emails.each do |email|
        SlackService.new.call(email, @ticket.id)
      end
      redirect_to user_dashboard_path, notice: 'New ticket has been reported'
    else
      @departments = Department.all.pluck(:name, :id)
      render :new
    end
  end

  def close
    @ticket = Ticket.find(params[:id])
    status_closed = Status.find_by(name: 'closed')
    @ticket.update(status_id: status_closed.id)
    if current_user.support?
      redirect_to show_tickets_path, notice: 'Ticket closed'
    else
      redirect_to user_dashboard_path, notice: 'Ticket closed'
    end
  end

  def search
    redirect_to user_dashboard_path, alert: 'Forbidden access' and return if current_user.user?
    query = params[:query]
    @tickets = Ticket.where('title LIKE ? OR note LIKE ?', "%#{query}%", "%#{query}%")
    if current_user.it_support?
      @tickets = @tickets.it_department
    elsif current_user.om_support?
      @tickets = @tickets.om_department
    end
  end

  private

  def ticket_params
    params.require(:ticket).permit(:title, :note, :status, :department_id, uploads: [])
  end
end
