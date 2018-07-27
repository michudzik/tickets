class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    if current_user
      redirect_to user_dashboard_path
    else
      redirect_to new_user_session_path
    end
  end
end
