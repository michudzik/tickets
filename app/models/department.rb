class Department < ActiveRecord::Base
  validates :name, presence: true
  validates :name, length: { maximum: 40 }

  has_many :tickets
end
