class UsersController < ApplicationController
  before_action :ensure_admin, only: [:index, :update, :deactivate_account]

  def show
  end

  def index
    @users = User.all
    @roles = Role.all.map { |role| [role.name, role.id] }
  end

  def update
    @user = User.find(params[:id])
    if @user.update(role_id: params[:user][:role_id])
      redirect_to users_url
    else
      render :index
    end
  end

  def deactivate_account
    @user = User.find(params[:id])
    if @user.update_attribute(:confirmed_at, nil)
      redirect_to users_url
    else
      render :index
    end
  end

  private

    def ensure_admin
      unless current_user.admin?
        redirect_to root_url, alert: 'No access'
      end
    end

end