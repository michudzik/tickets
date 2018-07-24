class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable,
        :validatable, :confirmable, :lockable

  validates :first_name,  presence: true
  validates :last_name,   presence: true
  belongs_to :role
  has_many :comments
  has_many :tickets

  before_validation :default_role, on: :create

  def admin?
    role.name == 'admin'
  end

  def it_support?
    role.name == 'it_support'
  end

  def om_support?
    role.name == 'om_support'
  end

  def none?
    self.role.name == 'none'
  end

  def support?
    om_support? || it_support? || admin?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def fullname
    "#{first_name} #{last_name}"
  end

  private

  def default_role
    self.role ||= Role.find_by(name: 'none')
  end
end
