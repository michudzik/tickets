class TicketsController < ApplicationController
  has_scope :ordered_by_title

  def index
    redirect_to user_dashboard_path, alert: 'Forbidden access' and return if current_user.user?

    if current_user.admin?
      @tickets = Ticket.all
    elsif current_user.om_support?
      @tickets = Ticket.om_department
    elsif current_user.it_support?
      @tickets = Ticket.it_department
    end

    case params[:filter_param]
    when "open"
      @tickets = @tickets.filtered_by_status_open
    when "support_response"
      @tickets = @tickets.filtered_by_status_support_response
    when "user_response"
      @tickets = @tickets.filtered_by_status_user_response
    when "closed"
      @tickets = @tickets.filtered_by_status_closed                     
    end

    case params[:sorted_by]
    when "title"
      @tickets = @tickets.ordered_by_title
    when "last_name"
      @tickets = @tickets.ordered_by_user_name
    when "department"
      @tickets = @tickets.ordered_by_department_om
    end

    @tickets = @tickets.paginate(page: params[:page], per_page: params[:number])
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
