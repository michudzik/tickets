class UsersController < ApplicationController
  before_action :ensure_admin, only: %i[index update deactivate_account activate_account]

  def show
    @tickets = current_user.tickets.paginate(page: params[:page], per_page: params[:number])
  end

  def index
    @roles = Role.all.map { |role| [role.name.humanize.to_s, role.id] }
    @users = User.all

    case params[:filter_param]
    when 'locked'
      @users = @users.locked
    when 'unlocked'
      @users = @users.unlocked
    end

    case params[:sorted_by]
    when 'last_name_asc'
      @users = @users.ordered_by_last_name_asc
    when 'last_name_desc'
      @users = @users.ordered_by_last_name_desc
    when 'email_asc'
      @users = @users.ordered_by_email_asc
    when 'email_desc'
      @users = @users.ordered_by_email_desc
    end

    @users = @users.paginate(page: params[:page], per_page: params[:number])
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
    if current_user.same_user?(params[:id].to_i)
      redirect_to(
        users_path,
        alert: 'You can not deactivate yourself'
      ) and return
    end
    @user = User.find(params[:id])
    respond_to do |format|
      @user.lock_access!(send_instructions: false)
      format.html { redirect_to users_path }
      format.js
    end
  end

  def activate_account
    if current_user.same_user?(params[:id].to_i)
      redirect_to(
        users_path,
        alert: 'You can not activate yourself'
      ) and return
    end
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
end
