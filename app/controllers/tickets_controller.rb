class TicketsController < ApplicationController
  def index
    Tickets::Index.new(current_user: current_user, params: params).call do |r|
      r.success do |tickets|
        @tickets = tickets
        @ticket_presenters = @tickets.map { |ticket| TicketPresenter.new(ticket) }
      end

      r.failure(:permission) { |_| redirect_to user_dashboard_path, alert: 'Forbidden access' }
      r.failure(:extract_tickets) { |_| redirect_to user_dashboard_path, alert: 'Lost connection to the database' }
      r.failure(:filter) { |_| redirect_to user_dashboard_path, alert: 'Lost connection to the database' }
      r.failure(:sort) { |_| redirect_to user_dashboard_path, alert: 'Lost connection to the database' }
    end
  end

  def show
    Tickets::Show.new(current_user: current_user).call(params[:id]) do |r|
      r.success do |ticket|
        @ticket = ticket
        @ticket_presenter = TicketPresenter.new(@ticket)
      end
      r.failure(:related_to_ticket) { |_| return redirect_to user_dashboard_path, alert: 'Forbidden access' }
    end

    Comments::List.new.call(@ticket) do |r|
      r.success do |comments|
        @comments = comments
        @comment_presenters = @comments.map { |comment| CommentPresenter.new(comment) }
      end
      r.failure(:extract_comments) { redirect_to user_dashboard_path, alert: 'Lost connection to the database' }
    end

    Comments::New.new.call(@ticket.id) do |r|
      r.success { |comment| @comment = comment }
      r.failure(:assign_object) { |comment| @comment = comment }
    end
  end

  def new
    Tickets::New.new.call(current_user) do |r|
      r.success do |ticket|
        @ticket = ticket
      end

      r.failure(:assign_object) { |ticket| @ticket = ticket }
    end

    Departments::List.new.call do |r|
      r.success { |departments| @departments = departments }
      r.failure(:extract_values) { |_| redirect_to user_dashboard_path, alert: 'Lost connection to the database' }
    end
  end

  def create
    Tickets::Create.new(current_user: current_user).call(ticket_params) do |r|
      r.success do |ticket|
        @ticket = ticket
        redirect_to user_dashboard_path, notice: 'New ticket has been reported'
      end

      r.failure(:validate) do |schema|
        @schema = schema
        Departments::List.new.call do |re|
          re.success do |departments|
            @departments = departments
            render :new
          end
          re.failure(:extract_values) do |_|
            redirect_to user_dashboard_path, alert: 'Lost connection to the database'
          end
        end
      end

      r.failure(:create_ticket) { |_| redirect_to user_dashboard_path, alert: 'Lost connection to the database' }
      r.failure(:notify_users_via_slack) do |ticket|
        @ticket = ticket
        redirect_to user_dashboard_path,
          notice: 'New ticket has been reported but slack failed to notify appropriate users'
      end
    end
  end

  def close
    Tickets::Close.new.call(params[:id]) do |r|
      r.success do |_|
        redirect_path = current_user.support? ? show_tickets_path : user_dashboard_path
        redirect_to redirect_path, notice: 'Ticket closed'
      end
      r.failure(:find_object) { |_| redirect_to user_dashboard_path, alert: 'Ticket not found' }
      r.failure(:change_status) { |_| redirect_to user_dashboard_path, alert: 'Lost connection to the database' }
    end
  end

  def search
    Tickets::Search.new(current_user: current_user, params: params[:query]).call do |r|
      r.success do |tickets|
        @tickets = tickets
        @ticket_presenters = @tickets.map { |ticket| TicketPresenter.new(ticket) }
      end
      r.failure { |_| redirect_to user_dashboard_path, alert: 'Forbidden access' }
    end
  end

  private

  def ticket_params
    params.require(:ticket).permit(:title, :note, :status, :department_id, uploads: [])
  end
end
