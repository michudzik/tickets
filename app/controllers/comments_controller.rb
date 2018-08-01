class CommentsController < ApplicationController
  def create
    @ticket = Ticket.find(params[:comment][:ticket_id])
    redirect_to ticket_path(@ticket.id), alert: 'This ticket is closed' and return if @ticket.status.status == 'closed'
    @comment = Comment.new(comment_params)
    respond_to do |format|
      if @comment.save
        @comment.update_ticket_status!(user: @comment.user, ticket: @ticket)
        UserNotifier.notify_users(@comment.ticket)
        @emails = @ticket.comments.joins(:user).distinct.pluck(:email)
        if !@emails.include?(@ticket.user.email)
          @emails.push(@ticket.user.email)
        end
        @emails.each do |email|
          SlackService.new.call(email) 
        end
        format.html { redirect_to ticket_path(@ticket.id), notice: 'Comment was created' }
        format.js
      else
        format.html { redirect_to ticket_path(@ticket.id), alert: 'There was an error while creating comment' }
      end
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :ticket_id).merge(user_id: current_user.id)
  end
end