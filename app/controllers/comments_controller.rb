class CommentsController < ApplicationController
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

end