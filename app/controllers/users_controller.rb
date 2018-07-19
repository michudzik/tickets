class UsersController < ApplicationController
  before_action :ensure_admin, only: [:index, :update, :deactivate_account]
  before_action :ensure_not_same_user, only: [:deactivate_account]

  def show
  end

  def index
    @users = User.where.not(id: current_user.id)
    @roles = Role.all.map { |role| [role.name.humanize.to_s, role.id] }
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

    def ensure_not_same_user
      if current_user == User.find(params[:id])
        redirect_to users_url, alert: 'You can not deactivate yourself'
      end
    end
end