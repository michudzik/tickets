class UserMailer < ApplicationMailer
  def notify
    @user = params[:user]
    @ticket = params[:ticket]
    status = @ticket.status.name.humanize
    user = @ticket.comments.last.user.fullname
    mail(
      to: @user.email,
      subject: "#{user} responded to \"#{@ticket.title}\" (status: #{status})"
    )
  end
end
