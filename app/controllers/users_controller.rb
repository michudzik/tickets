class UsersController < ApplicationController
  before_action :ensure_admin, only: %i[index update deactivate_account activate_account]

  def show
    Users::Show.new(params: params, current_user: current_user).call do |r|
      r.success do |tickets|
        @tickets = tickets
        @ticket_presenters = @tickets.map { |ticket| TicketPresenter.new(ticket) }
      end
      r.failure(:extract_tickets) { redirect_to user_path(current_user.id), alert: 'Lost connection to the database' }
    end
  end

  def index
    Users::Index.new(params: params).call do |r|
      r.success do |users|
        @users = users
      end

      r.failure(:users) { |_| return redirect_to users_path, alert: 'Lost connection to the database' }
      r.failure(:filter) { |_| return redirect_to users_path, alert: 'Lost connection to the database' }
      r.failure(:sort) { |_| return redirect_to users_path, alert: 'Lost connection to the database' }
    end

    Roles::List.new.call do |r|
      r.success { |roles| @roles = roles }
      r.failure(:extract_values) { redirect_to users_path, alert: 'Lost connection to the database' }
    end
  end

  def update
    Users::Update.new(params: user_params).call(params[:id]) do |r|
      r.success do |user|
        @user = user
        respond_to do |format|
          format.html { redirect_to users_path, notice: "You have successfully changed the role of #{@user.fullname}" }
          format.js
        end
      end
      r.failure(:assign_object) { |_| redirect_to users_path, alert: 'User not found' }
      r.failure(:validate) { |_| render :index }
      r.failure(:persist) { |_| redirect_to users_path, alert: 'Lost connection to database' }
    end
  end

  def deactivate_account
    Users::DeactivateAccount.new(current_user: current_user).call(params[:id]) do |r|
      r.success do |user|
        @user = user
        respond_to do |format|
          format.html { redirect_to users_path }
          format.js
        end
      end

      r.failure(:assign_object) { |_| redirect_to users_path, alert: 'User not found' }
      r.failure(:same_user) { |_| redirect_to users_path, alert: 'You can not deactivate yourself' }
    end
  end

  def activate_account
    Users::ActivateAccount.new(current_user: current_user).call(params[:id]) do |r|
      r.success do |user|
        @user = user
        respond_to do |format|
          format.html { redirect_to users_path }
          format.js
        end
      end

      r.failure(:assign_object) { |_| redirect_to users_path, alert: 'User not found' }
      r.failure(:same_user) { |_| redirect_to users_path, alert: 'You can not activate yourself' }
    end
  end

  private

  def user_params
    params.require(:user).permit(:role_id)
  end
end
