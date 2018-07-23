class Department < ActiveRecord::Base
  validates :department_name, presence: true
  validates :department_name, length: { maximum: 40 }

  has_many :tickets
end