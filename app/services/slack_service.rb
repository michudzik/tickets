require 'slack-ruby-client'

class SlackService
  def initialize
    @client = Slack::Web::Client.new
    @client.auth_test
  end

  def call(email, webpath)
    user_id = find_user(email)
    request = @client.im_open(user: user_id)
    channel = request.channel
    @client.chat_postMessage(
      channel: channel.id,
      text: "You have new update on your ticket: #{web_url}/tickets/#{webpath}"
    )
  rescue ArgumentError
    false
  end

  private

  def find_user(email)
    user_list = @client.users_list
    users = user_list.members.select { |member| member.profile.email == email }
    raise ArgumentError, "User with that email can't be found" if users.empty?
    users.first.id
  end

  def web_url
    if Rails.env.development?
      'http://localhost:3000'
    else
      'http://tickets.binarlab.com'
    end
  end
end
