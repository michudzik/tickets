class CommentsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "comments_#{params['ticket_id']}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_comment(data)
    current_user.comments.create!(body: data['body'], ticket_id: data['ticket_id'])
  end
end
