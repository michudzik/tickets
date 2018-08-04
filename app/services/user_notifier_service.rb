class UserNotifierService
  def initialize(options = {})
    @ticket = options[:ticket]
    @current_user = options[:current_user]
  end

  def call
    recipients = select_recipients
    notify(recipients)
  end

  private

  def select_recipients
    recipients = @ticket.comments.where.not(user_id: @current_user.id).pluck(:user_id)
    recipients.append(@ticket.user.id) if recipients.empty? && @ticket.user.id != @current_user.id
    recipients
  end

  def notify(recipients)
    users = User.find(recipients)
    users.each do |user|
      UserMailer.with(user: user, ticket: @ticket).notify.deliver_later
    end
  end
end
