class UsersController < ApplicationController
  before_action :ensure_admin, only: [:index, :update, :deactivate_account, :activate_account]

  def show
  end

  def index
    @users = User.where.not(id: current_user.id)
    @roles = Role.all.map { |role| [role.name.humanize.to_s, role.id] }
  end

  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update(role_id: params[:user][:role_id])
        format.html { redirect_to users_url }
        format.js
      else
        format.html { render :index }
      end
    end
  end

  def deactivate_account
    #same_user('You can not deactivate yourself')
    @user = User.find(params[:id])
    respond_to do |format|
      @user.lock_access!(send_instructions: false)
      format.html { redirect_to users_url }
      format.js
    end
  end

  def activate_account
    redirect_to users_path, notice: 'You can not deactivate yourself', params: {test: 123} and return if current_user.id == params[:id] 
    #same_user('You can not activate yourself')
    @user = User.find(params[:id])
    respond_to do |format|
      @user.unlock_access!
      format.html { redirect_to users_url }
      format.js
    end
  end

  private

  def same_user(msg)
    
  end
end