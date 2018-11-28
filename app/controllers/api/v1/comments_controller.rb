class Api::V1::CommentsController < Api::V1::ApiController
  def create
    Comments::Create.new(current_user: current_user, params: comment_params).call do |r|
      r.success { |ticket| @comment = ticket.comments.last }
      r.failure(:assign_ticket) { |_| render json: { errors: 'Ticket not found' }, status: :not_found }
      r.failure(:closed) { |_| render json: { errors: 'This ticket is closed' }, status: :unprocessable_entity } 
      r.failure(:validate) { |_| render json: { errors: 'Comment is empty' }, status: :unprocessable_entity }
      r.failure(:create_comment) { |_| render json: { errors: 'Lost connection to the database' }, status: :internal_server_error }
    end
  end

  def comment_params
    params.require(:comment).permit(:body, :ticket_id, uploads: []).merge(user_id: current_user.id)
  end
end
