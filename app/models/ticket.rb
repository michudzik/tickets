class Ticket < ActiveRecord::Base
    
    belongs_to :user

    validates :note, presence: true, length: { in: 30..500}
    validates :title, presence: true, length: { in: 10..30}

    def fullticket
        " #{user_id} #{title} #{note} #{department} #{status} "
    end

end