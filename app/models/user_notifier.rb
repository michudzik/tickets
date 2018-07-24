class UserNotifier
  def self.notify_users(user_ids, ticket)
    unless user_ids.empty?
      users = User.find(user_ids)
      users.each do |user|
        UserMailer.with(user: user, ticket: ticket).notify.deliver_later
      end
    end
  end
end
