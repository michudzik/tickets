class CommentsController < ApplicationController
	before_action :ensure_ticket_not_closed

	def create
		@comment = Comment.create(comment_params)
		respond_to do |format|
			if @comment.save
				format.html { redirect_to user_dashboard_path, notice: 'Comment was created' }
				format.js
			else
				format.html { redirect_to user_dashboard_path, alert: 'There was an error while creating comment' }
			end
		end
	end

	private
	def comment_params
		params.require(:comment).permit(:body, :ticket_id).merge(user_id: current_user.id)
	end

	def ensure_ticket_not_closed
		@ticket = Ticket.find(params[:comment][:ticket_id])
		if @ticket.status.status == 'closed'
			redirect_to ticket_path(@ticket.id), alert: 'This ticket is closed'
		end
	end

end