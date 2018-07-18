class CommentsController < ApplicationController

	def create
		@user = User.find(params[:user_id])
		@comment = @user.comments.create(comment_params)
		respond_to do |format|
			if @comment.save
				format.html { redirect_to request.referrer, notice: 'Comment was created' }
				format.js
			else
				format.html { redirect_to request.referrer, alert: 'There was an error while creating comment' }
			end
		end
	end

	def destroy
		@comment = Comment.find(params[:id])
		respond_to do |format|
			if @comment.destroy
				format.html { redirect_to request.referrer, notice: 'Comment was deleted' }
				format.js
			else
				format.html { redirect_to request.referrer, alert: 'There was an error while deleting comment' }
			end
		end
	end

	private
	def comment_params
		params.require(:comment).permit(:body, :commenter_id)
	end

end