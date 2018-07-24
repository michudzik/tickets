class Department < ActiveRecord::Base
  validates :department_name, presence: true, length: { maximum: 40 }

  has_many :tickets
end