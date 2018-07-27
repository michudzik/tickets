class Ticket < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :department
  has_many :comments
  belongs_to :status
  has_many_attached :uploads

  validates :note, presence: true, length: { maximum: 500 }
  validates :title, presence: true, length: { maximum: 30 }
  validates :department, presence: true

  before_validation :default_status, on: :create

  scope :it_department, -> { joins(:department).where(departments: { department_name: 'IT'}) }
  scope :om_department, -> { joins(:department).where(departments: { department_name: 'OM'}) }

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
      (current_user.it_support? && department.department_name == 'IT') ||
      (current_user.om_support? && department.department_name == 'OM')
  end

  def notify_users(user_ids)
    unless user_ids.empty?
      users = User.find(user_ids)
      users.each do |user|
        UserMailer.with(user: user, ticket: slef).notify.deliver_later
      end
    end
  end

  def self.find_related_tickets(current_user)
    if current_user.admin?
      all
    elsif current_user.om_support?
      om_department
    elsif current_user.it_support?
      it_department
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
