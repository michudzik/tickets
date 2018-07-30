class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  WillPaginate.per_page = 10

  protected

  def ensure_admin
    redirect_to(root_url, alert: 'No access') unless current_user.admin?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name])
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: %i[first_name last_name password password_confirmation current_password]
    )
  end
end
