class CommentBroadcastJob < ApplicationJob
  queue_as :default

  def perform(comment)
    ActionCable.server.broadcast "comments_#{comment.ticket.id}_channel", body: render_comment(comment)
  end

  private

  def render_comment(comment)
    CommentsController.render partial: 'comments/comment', locals: { comment: comment, align: 'left' }
  end
end
