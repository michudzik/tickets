#hnotifier = Slack::Notifier.new "WEBHOOK_URL" do
  #  defaults channel: "#default",
  #           username: "notifier"
  #end
  
  #notifier.ping "Hello default"
  # => will message "Hello default"
  # => to the "#default" channel as 'notifier'

  Slack.configure do |config|
    config.token = 'xoxb-393256541287-407979571746-g62Jc3UmSg0qnVBKG0bev5B5'
  end 