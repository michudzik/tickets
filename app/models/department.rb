class Department < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 40 }

  has_many :tickets, dependent: :nullify
end
