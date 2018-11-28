module Slack
  class TicketsCreate < ApplicationTransaction
    ERRORS = [ArgumentError, Slack::Web::Api::Errors::SlackError, Slack::Web::Api::Errors::TooManyRequestsError].freeze

    map :find_department
    try :pick_emails, catch: ActiveRecord::ActiveRecordError
    try :send_notifications, catch: ERRORS

    private

    def find_department
      current_params.department.name == 'IT' ? 'it_support' : 'om_support'
    end

    def pick_emails(department)
      emails = User.joins(:role).where(roles: { name: department }).distinct.pluck(:email)
      emails.delete(current_user.email)
      emails
    end

    def send_notifications(emails)
      emails.each { |email| SlackService.new.call(email, current_params.id) } if emails.any?
    end
  end
end
