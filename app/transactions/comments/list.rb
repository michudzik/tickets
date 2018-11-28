module Comments
  class List < ApplicationTransaction
    try :extract_comments, catch: ActiveRecord::ActiveRecordError

    private

    def extract_comments(ticket)
      ticket.comments.order(created_at: :asc)
    end
  end
end
