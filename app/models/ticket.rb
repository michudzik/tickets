class Ticket < ActiveRecord::Base
    
    belongs_to :user
    belongs_to :department
    belongs_to :status

    validates :note, presence: true, length: { in: 20..500}
    validates :title, presence: true, length: { in: 5..30}
    validates :user_id, presence: true
    validates :department, presence: true

    before_validation :default_status, on: :create

    def fullticket
        " #{user_id} #{title} #{note} #{department} #{status} "
    end


    private

      def default_status
        self.status ||= Status.find_by(status: 'open')
      end
end