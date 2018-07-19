class Ticket < ActiveRecord::Base
    
    belongs_to :user
    belongs_to :department
    has_many :comments

    validates :note, presence: true, length: { maximum: 500}
    validates :title, presence: true, length: { maximum: 30}

    def fullticket
        " #{user_id} #{title} #{note} #{department} #{status} "
    end

end