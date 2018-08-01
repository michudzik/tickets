class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable,
    :validatable, :confirmable, :lockable

  validates :first_name, :last_name, presence: true
  belongs_to :role
  has_many :comments, dependent: :nullify
  has_many :tickets, dependent: :nullify

  before_validation :default_role, on: :create

  scope :unlocked,              -> { where(:locked_at => nil) }
  scope :locked,                -> { where.not(:locked_at => nil) }
  scope :ordered_by_first_name, -> { order('lower(first_name)') }
  scope :ordered_by_last_name,  -> { order('lower(last_name)') }
  scope :ordered_by_email,      -> { order('lower(email)') }

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

  def same_user?(user_id)
    id == user_id
  end

  def fullname
    "#{first_name} #{last_name}"
  end

  private

  def default_role
    self.role ||= Role.find_by(name: 'user')
  end
end
