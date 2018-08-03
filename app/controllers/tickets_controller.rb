class TicketsController < ApplicationController

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
    when "title_asc"
      @tickets = @tickets.ordered_by_title_asc
    when "title_desc"
      @tickets = @tickets.ordered_by_title_desc
    when "user_name_asc"
      @tickets = @tickets.ordered_by_user_name_asc
    when "user_name_desc"
      @tickets = @tickets.ordered_by_user_name_desc
    when "department_om"
      @tickets = @tickets.ordered_by_department_om
    when "department_it"
      @tickets = @tickets.ordered_by_department_it
    else
      @tickets = @tickets.ordered_by_date     
    end

    @tickets = @tickets.paginate(page: params[:page], per_page: params[:number])
  end

  def show
    @ticket = Ticket.find(params[:id])
    @comments = @ticket.comments.order(created_at: :asc)
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
      if @ticket.department.name == 'IT'
        @emails = User.joins(:role).where(roles: {name: 'it_support'}).distinct.pluck(:email)
      else
        @emails = User.joins(:role).where(roles: {name: 'om_support'}).distinct.pluck(:email)
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
