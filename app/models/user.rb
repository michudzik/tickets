class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable,
    :validatable, :confirmable, :lockable

  validates :first_name, :last_name, presence: true
  belongs_to :role
  has_many :comments, dependent: :nullify
  has_many :tickets, dependent: :nullify

  before_validation :default_role, on: :create

  scope :unlocked,                     -> { where(locked_at: nil) }
  scope :locked,                       -> { where.not(locked_at: nil) }
  scope :ordered_by_last_name_asc,     -> { order(Arel.sql('lower(last_name) ASC')) }
  scope :ordered_by_last_name_desc,    -> { order(Arel.sql('lower(last_name) DESC')) }
  scope :ordered_by_email_asc,         -> { order(Arel.sql('lower(email) ASC')) }
  scope :ordered_by_email_desc,        -> { order(Arel.sql('lower(email) DESC')) }

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

  def self.filter_users(status)
    case status
    when 'locked'
      locked
    when 'unlocked'
      unlocked
    else
      all
    end
  end

  def self.sort_users(by)
    case by
    when 'last_name_asc'
      ordered_by_last_name_asc
    when 'last_name_desc'
      ordered_by_last_name_desc
    when 'email_asc'
      ordered_by_email_asc
    when 'email_desc'
      ordered_by_email_desc
    else
      all
    end
  end

  private

  def default_role
    self.role ||= Role.find_by(name: 'user')
  end
end
