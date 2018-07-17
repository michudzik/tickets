class UsersController < ApplicationController
  before_action :ensure_correct_user

  def show
    @current_user = User.find(current_user.id)
  end

  private

    def ensure_correct_user
      @user = User.find(params[:id])
      unless current_user == @user
        redirect_to root_url
      end
    end
end