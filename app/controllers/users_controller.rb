class UsersController < ApplicationController
  def show
    @current_user = User.find(current_user.id)
  end
end