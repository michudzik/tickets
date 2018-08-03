class Ticket < ActiveRecord::Base
  belongs_to :user
  belongs_to :department
  has_many :comments, dependent: :nullify
  belongs_to :status
  has_many_attached :uploads

  validates :note, presence: true, length: { maximum: 500 }
  validates :title, presence: true, length: { maximum: 50 }
  validates :department, presence: true

  before_validation :default_status, on: :create

  scope :it_department,                          -> { joins(:department).where(departments: { name: 'IT' }) }
  scope :om_department,                          -> { joins(:department).where(departments: { name: 'OM' }) }
  scope :ordered_by_date,                        -> { order(created_at: :desc) }
  scope :ordered_by_title_asc,                   -> { order('lower(title) ASC') }
  scope :ordered_by_title_desc,                  -> { order('lower(title) DESC') }
  scope :ordered_by_user_name_asc,               -> { joins(:user).order('lower(users.last_name) ASC') }
  scope :ordered_by_user_name_desc,              -> { joins(:user).order('lower(users.last_name) DESC') }
  scope :ordered_by_department_om,               -> { joins(:department).order('departments.name DESC') }
  scope :ordered_by_department_it,               -> { joins(:department).order('departments.name ASC') }
  scope :filtered_by_status_open,                -> { joins(:status).where(statuses: { name: 'open' }) }
  scope :filtered_by_status_support_response,    -> { joins(:status).where(statuses: { name: 'support_response' }) }
  scope :filtered_by_status_user_response,       -> { joins(:status).where(statuses: { name: 'user_response' }) }
  scope :filtered_by_status_closed,              -> { joins(:status).where(statuses: { name: 'closed' }) }

  def user_response
    self.status = find_status('user_response')
  end

  def support_response
    self.status = find_status('support_response')
  end

  def closed?
    status.name == 'closed'
  end

  def related_to_ticket?(current_user)
    user == current_user || current_user.admin? ||
      (current_user.it_support? && department.name == 'IT') ||
      (current_user.om_support? && department.name == 'OM')
  end

  def notify_users(user_ids)
    users = User.find(user_ids)
    users.each do |user|
      UserMailer.with(user: user, ticket: self).notify.deliver_later
    end
  end

  private

  def default_status
    self.status ||= find_status('open')
  end

  def find_status(name)
    Status.find_by(name: name)
  end
end
