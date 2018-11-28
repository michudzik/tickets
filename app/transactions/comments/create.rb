require 'net/smtp'

module Comments
  class Validator
    attr_reader :schema

    def initialize
      @schema = Dry::Validation.Schema do
        required(:body).filled
      end
    end
  end

  class Create < ApplicationTransaction
    SMTP_ERRORS = [
      Net::SMTPAuthenticationError,
      Net::SMTPServerBusy,
      Net::SMTPSyntaxError,
      Net::SMTPFatalError,
      Net::SMTPUnknownError
    ].freeze

    try :assign_ticket, catch: ActiveRecord::RecordNotFound
    check :closed
    step :validate
    try :create_comment, catch: ActiveRecord::ActiveRecordError
    try :change_ticket_status, catch: ActiveRecord::ActiveRecordError
    map :extract_ticket
    try :notify_users_via_email, catch: SMTP_ERRORS
    step :notify_users_via_slack
  
    private

    def assign_ticket
      ::Ticket.find(current_params[:ticket_id])
    end

    def closed(ticket)
      ticket.open?
    end

    def validate(ticket)
      attr = { ticket_id: ticket.id, user_id: current_params[:user_id], body: current_params[:body] }
      schema = Validator.new.schema.call(attr)
      return Success(attr) if schema.success?
      Failure(schema)
    end

    def create_comment(attr)
      ::Comment.create(ticket_id: attr[:ticket_id], user_id: attr[:user_id], body: attr[:body])
    end

    def change_ticket_status(comment)
      comment.update_ticket_status!(user: comment.user, ticket: comment.ticket)
      comment
    end

    def extract_ticket(comment)
      comment.ticket
    end

    def notify_users_via_email(ticket)
      UserNotifierService.new(ticket: ticket, current_user: current_user).call
      ticket
    end

    def notify_users_via_slack(ticket)
      Slack::CommentsCreate.new(current_user: current_user, params: ticket).call do |r|
        r.success { |_| Success(ticket) }
        r.failure { |_| Failure(ticket) }
      end
    end
  end
end
