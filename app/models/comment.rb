class Comment < ActiveRecord::Base
  validates :body, presence: true

  belongs_to :user
  belongs_to :ticket
  has_many_attached :uploads

  after_create_commit { CommentBroadcastJob.perform_later(self) }

  def update_ticket_status!(options = {})
    options[:user].id == options[:ticket].user.id ? options[:ticket].user_response : options[:ticket].support_response
    options[:ticket].save
  end
end
