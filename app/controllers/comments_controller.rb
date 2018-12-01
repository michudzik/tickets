class CommentsController < ApplicationController
  def create
    Comments::Create.new(current_user: current_user, params: comment_params).call do |r|
      r.success do |ticket|
        @ticket = ticket
        respond_to do |format|
          format.html { redirect_to ticket_path(@ticket.id), notice: 'Comment created' }
          format.js
        end
      end
      r.failure(:assign_ticket) { |_| redirect_to user_dashboard_url, alert: 'Ticket not found' }
      r.failure(:closed) { |ticket| redirect_to ticket_path(ticket.id), alert: 'This ticket is closed' }
      r.failure(:validate) { |schema| redirect_to ticket_path(schema[:ticket_id]), alert: 'Comment is empty' }
      r.failure(:create_comment) { |_| redirect_to root_path, alert: 'Lost connection to the database' }
      r.failure(:notify_users_via_slack) do |ticket|
        redirect_to ticket_path(ticket.id), notice: 'Comment created, but Slack failed to send notifications'
      end
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :ticket_id, uploads: []).merge(user_id: current_user.id)
  end
end
