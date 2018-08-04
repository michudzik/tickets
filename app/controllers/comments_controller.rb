class CommentsController < ApplicationController
  def create
    @ticket = Ticket.find(params[:comment][:ticket_id])
    redirect_to ticket_path(@ticket.id), alert: 'This ticket is closed' and return if @ticket.closed?
    @comment = Comment.new(comment_params)
    respond_to do |format|
      if @comment.save
        @comment.update_ticket_status!(user: @comment.user, ticket: @ticket)
        UserNotifierService.new(ticket: @comment.ticket, current_user: current_user).call
        @emails = @ticket.comments.joins(:user).distinct.pluck(:email)
        @emails.push(@ticket.user.email) unless @emails.include?(@ticket.user.email)
        @emails.delete(current_user.email)
        @emails.each do |email|
          SlackService.new.call(email, @ticket.id)
        end
        format.html { redirect_to ticket_path(@ticket.id), notice: 'Comment was created' }
        format.js
      else
        format.html { redirect_to ticket_path(@ticket.id), alert: 'Couldn\'t create comment without any text' }
      end
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :ticket_id, uploads: []).merge(user_id: current_user.id)
  end
end
