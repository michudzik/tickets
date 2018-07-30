class UserMailer < ApplicationMailer
  def notify
    @user = params[:user]
    @ticket = params[:ticket]
    mail(
      to: @user.email,
      subject: "Someone responded to - #{@ticket.title}. Status - #{@ticket.status.name.humanize}"
    )
  end
end
