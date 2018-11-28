class Api::V1::UsersController < Api::V1::ApiController
  def show
    Users::Show.new(params: params, current_user: current_user).call do |r|
      r.success do |tickets|
        @tickets = tickets
        @user = current_user
      end

      r.failure(:extract_tickets) { render json: { errors: 'Lost connection to the database' }, status: :internal_server_error }
    end
  end

  def index
    Users::Index.new(params: params).call do |r|
      r.success { |users| @users = users }
      r.failure(:users) { |_| render json: { errors: 'Lost connection to the database' }, status: :internal_server_error }
      r.failure(:filter) { |_| render json: { errors: 'Lost connection to the database' }, status: :internal_server_error }
      r.failure(:sort) { |_| render json: { errors: 'Lost connection to the database' }, status: :internal_server_error }
    end
  end

  def update
    Users::Update.new(params: user_params).call(params[:id]) do |r|
      r.success { |user| @user = user }
      r.failure(:assign_object) { |_| render json: { errors: 'User not found' }, status: :not_found }
      r.failure(:validate) { |user| render json: { errors: user.errors }, status: :unprocessable_entity }
      r.failure(:persist) { |_| render json: { errors: 'Lost connection to the database' }, status: :internal_server_error }
    end
  end

  def deactivate_account
    Users::DeactivateAccount.new(current_user: current_user).call(params[:id]) do |r|
      r.success { |user| @user = user }
      r.failure(:assign_object) { |_| render json: { errors: 'User not found' }, status: :not_found }
      r.failure(:same_user) { |_| render json: { errors: 'You can not deactivate yourself' }, status: :unprocessable_entity }
    end
  end

  def activate_account
    Users::ActivateAccount.new(current_user: current_user).call(params[:id]) do |r|
      r.success { |user| @user = user }
      r.failure(:assign_object) { |_| render json: { errors: 'User not found' }, status: :not_found }
      r.failure(:same_user) { |_| render json: { errors: 'You can not activate yourself' }, status: :unprocessable_entity }
    end
  end

  private

  def user_params
    params.require(:user).permit(:role_id)
  end
end
