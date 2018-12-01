module Tickets
  class Validator
    attr_reader :schema

    def initialize
      @schema = Dry::Validation.Schema do
        required(:note).filled(max_size?: 500)
        required(:title).filled(max_size?: 50)
        required(:department_id).filled
      end
    end
  end

  class Create < ApplicationTransaction
    step :validate
    try :create_ticket, catch: ActiveRecord::ActiveRecordError
    step :notify_users_via_slack

    private

    def validate(ticket_params)
      schema = Validator.new.schema.call(ticket_params)
      return Success(ticket_params) if schema.success?

      Failure(schema)
    end

    def create_ticket(ticket_params)
      current_user.tickets.create(ticket_params)
    end

    def notify_users_via_slack(ticket)
      Slack::TicketsCreate.new(current_user: current_user, params: ticket).call do |r|
        r.success { |_| Success(ticket) }
        r.failure { |_| Failure(ticket) }
      end
    end
  end
end
