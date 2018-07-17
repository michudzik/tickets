class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates :first_name,  presence: true
  validates :last_name,   presence: true
  belongs_to :role

  before_validation :default_role, on: :create

  def admin?
    self.role.name == 'admin'
  end

  def it_support?
    self.role.name == 'it_support'
  end

  def om_support?
    self.role.name == 'om_support'
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

    def default_role
      self.role ||= Role.find_by(name: 'none')
    end

end
