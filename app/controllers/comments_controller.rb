class CommentsController < ApplicationController
	def create
		@comment = current_user.comments.create(comment_params)
		respond_to do |format|
			if @comment.save
				format.html { redirect_to user_dashboard_path, notice: 'Comment was created' }
				format.js
			else
				format.html { redirect_to user_dashboard_path, alert: 'There was an error while creating comment' }
			end
		end
	end

	def destroy
		@comment = Comment.find(params[:id])
		if @comment.destroy
			redirect_to request.referrer, notice: 'Comment was deleted'
		else
			redirect_to request.referrer, alert: 'There was an error while deleting comment'
		end
	end

	private
	def comment_params
		params.require(:comment).permit(:body)
	end

end