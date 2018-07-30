class Comment < ActiveRecord::Base
  validates :body, presence: true

  belongs_to :user
  belongs_to :ticket

  after_create_commit { CommentBroadcastJob.perform_later(self) }

  def update_ticket_status!(options = {})
    same_user = options[:user].id == options[:ticket].user.id
    same_user ? options[:ticket].user_response : options[:ticket].support_response
    options[:ticket].save
  end
end