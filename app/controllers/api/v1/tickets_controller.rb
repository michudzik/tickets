class Api::V1::TicketsController < Api::V1::ApiController
  def index
    Tickets::Index.new(current_user: current_user, params: params).call do |r|
      r.success { |tickets| @tickets = tickets }
      r.failure(:permission) { |_| render json: { errors: 'Forbidden access' }, status: :forbidden }
      r.failure(:extract_tickets) { |_| render json: { errors: 'Lost connection to the database' }, status: :internal_server_error }
      r.failure(:filter) { |_| render json: { errors: 'Lost connection to the database' }, status: :internal_server_error }
      r.failure(:sort) { |_| render json: { errors: 'Lost connection to the database' }, status: :internal_server_error }
    end
  end

  def show
    Tickets::Show.new(current_user: current_user).call(params[:id]) do |r|
      r.success { |ticket| @ticket = ticket }
      r.failure(:assign_object) { |_| return render json: { errors: 'Ticket not found' }, status: :not_found }
      r.failure(:related_to_ticket) { |_| return render json: { errors: 'Forbidden access' }, status: :forbidden }
    end

    Comments::List.new.call(@ticket) do |r|
      r.success { |comments| @comments = comments }
      r.failure(:extract_comments) { render json: { errors: 'Lost connection to the database' }, status: :internal_server_error }
    end
  end

  def create
    Tickets::Create.new(current_user: current_user).call(ticket_params) do |r|
      r.success { |ticket| @ticket = ticket }
      r.failure(:validate) { |schema| render json: { errors: schema.errors }, status: :unprocessable_entity }
      r.failure(:create_ticket) { |_| render json: { errors: 'Lost connection to the database' }, status: :internal_server_error }
    end
  end

  def close
    Tickets::Close.new.call(params[:id]) do |r|
      r.success { |ticket| @ticket = ticket }
      r.failure(:find_object) { |_| render json: { errors: 'Ticket not found' }, status: :not_found }
      r.failure(:change_status) { |_| render json: { errors: 'Lost connection to the database' }, status: :internal_server_error }
    end
  end

  def search
    Tickets::Search.new(current_user: current_user, params: params[:query]).call do |r|
      r.success { |tickets| @tickets = tickets }
      r.failure(:permission) { |_| render json: { errors: 'Forbidden access' }, status: :forbidden }
      r.failure(:filter) { |_| render json: { errors: 'Lost connection to the database'}, status: :internal_server_error }
    end
  end

  private

  def ticket_params
    params.require(:ticket).permit(:title, :note, :status, :department_id, uploads: [])
  end
end
