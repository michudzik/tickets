class Ticket < ActiveRecord::Base
    
    belongs_to :user

    validates :note, presence: true, length: { in: 20..500}
    validates :title, presence: true, length: { in: 5..30}
    validates :user_id, presence: true
    validates :department, presence: true

    def fullticket
        " #{user_id} #{title} #{note} #{department} #{status} "
    end

end