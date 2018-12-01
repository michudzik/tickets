module Slack
  class CommentsCreate < ApplicationTransaction
    ERRORS = [ArgumentError, Slack::Web::Api::Errors::SlackError, Slack::Web::Api::Errors::TooManyRequestsError].freeze

    try :extract_email, catch: ActiveRecord::ActiveRecordError
    map :remove_current_user_email
    try :notify_users, catch: ERRORS

    private

    def extract_email(*_args)
      emails = current_params.comments.joins(:user).distinct.pluck(:email)
      emails = emails.push(current_params.user.email) unless emails.include?(current_params.user.email)
      emails
    end

    def remove_current_user_email(emails)
      emails.delete(current_user.email)
      emails
    end

    def notify_users(emails)
      emails.each { |email| SlackService.new.call(email, current_params.id) }
    end
  end
end
