class Ticket < ActiveRecord::Base
    
    belongs_to :user
    belongs_to :department

    validates :note, presence: true, length: { maximum: 500}
    validates :title, presence: true, length: { maximum: 30}
    validates :user_id, presence: true
    validates :department, presence: true

    def fullticket
        " #{user_id} #{title} #{note} #{department} #{status} "
    end

end