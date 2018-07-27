class UsersController < ApplicationController

  before_action :ensure_admin, only: %i[index update deactivate_account activate_account]

  def show
    @tickets = current_user.tickets.paginate(:page => params[:page], :per_page => params[:number])
  end

  def index
    @users = User.where.not(id: current_user.id).paginate(:page => params[:page], :per_page => params[:number])
    @roles = Role.all.map { |role| [role.name.humanize.to_s, role.id] }
  end

  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: "You have successfully changed the role of #{@user.fullname}" }
        format.js
      else
        format.html { render :index }
      end
    end
  end

  def deactivate_account
    same_user('You can not deactivate yourself')
    @user = User.find(params[:id])
    respond_to do |format|
      @user.lock_access!(send_instructions: false)
      format.html { redirect_to users_path }
      format.js
    end
  end

  def activate_account
    same_user('You can not activate yourself')
    @user = User.find(params[:id])
    respond_to do |format|
      @user.unlock_access!
      format.html { redirect_to users_path }
      format.js
    end
  end

  private

  def user_params
    params.require(:user).permit(:role_id)
  end

  def same_user(msg)
    redirect_to users_path, alert: msg and return if current_user.id == params[:id]
  end
end
