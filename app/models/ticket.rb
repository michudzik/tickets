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

  def user_response
      self.status = find_status('user_response')
  end

  def support_response
    self.status = find_status('support_response')
  end

  def closed?
    status.status == 'closed'
  end

  private

  def default_status
    self.status ||= find_status('open')
  end

  def find_status(name)
    Status.find_by(status: name)
  end
end
