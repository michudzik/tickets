module Comments
  class New < ApplicationTransaction
    map :assign_object

    private

    def assign_object(ticket_id)
      ::Comment.new(ticket_id: ticket_id)
    end
  end
end
