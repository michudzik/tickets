class HomeController < ApplicationController

  def home
    if current_user
      # redirect_to user_show_url
    else
      redirect_to new_user_session_url
    end
  end

end