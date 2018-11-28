class ApplicationTransaction
  include Dry::Transaction

  def current_user
    operations[:current_user]
  end

  def current_params
    operations[:params]
  end
end
