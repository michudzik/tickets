class HomeController < ApplicationController
  skip_before_action :authenticate_user!


  def home
    if current_user
      unless current_user.confirmed_at.nil?
        redirect_to new_user_confirmation_url
      else
        redirect_to user_url(current_user.id)
      end
    else
      redirect_to new_user_session_url
    end
  end

end