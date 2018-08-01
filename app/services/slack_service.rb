require 'slack-ruby-client'

class SlackService
  
  def initialize
    @client = Slack::Web::Client.new
    @client.auth_test
  end

  def call (email)
    begin
    user_id = find_user(email)
    request = @client.im_open(user: user_id)
    channel_id = request.channel
    @client.chat_postMessage(
      channel: channel_id,
      text: 'You have new update on your ticket'
    )
    end
  end

  private

  def find_user(email)
    user_list = @client.users_list
    users = user_list.members.select { |member| member.profile.email == email}
    raise ArgumentError, "User with that email can't be found" if users.empty?
    users.first.user_id
  end
end
