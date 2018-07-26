class UserNotifier

  def self.notify_users(ticket)
    users = ticket.comments.pluck(:user_id)
    users = User.find(users)

    users.each do |user|
      UserMailer.with(user: user, ticket: ticket).notify.deliver_later
    end
  end
end