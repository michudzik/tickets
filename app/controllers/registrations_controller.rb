class RegistrationsController < ApplicationController
  before_action :ensure_user_logged_in


  def edit
    @current_user = User.find(current_user.id)
  end

  def update
    @current_user = User.find(current_user.id)
    if @current_user.update(user_params)
      # Redirect to user_path
    else
      render :edit
    end
  end

  private

    def ensure_user_logged_in
      unless user_signed_in?
        redirect_to new_user_session_url, alert: 'Please, log in'
      end
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name)
    end

end