class User < ApplicationRecord

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable,
    :validatable, :confirmable, :lockable

  validates :first_name, :last_name,  presence: true
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

  def user?
    role.name == 'user'
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
    self.role ||= Role.find_by(name: 'user')
  end
end