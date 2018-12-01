class Api::V1::UsersController < Api::V1::ApiController
  def show
    Users::Show.new(params: params, current_user: current_user).call do |r|
      r.success do |tickets|
        @tickets = tickets
        @user = current_user
      end

      r.failure(:extract_tickets) do
        render json: { errors: 'Lost connection to the database' }, status: :internal_server_error
      end
    end
  end

  def index
    Users::Index.new(params: params).call do |r|
      r.success { |users| @users = users }
      r.failure do
        render json: { errors: 'Lost connection to the database' }, status: :internal_server_error
      end
    end
  end

  def update
    Users::Update.new(params: user_params).call(params[:id]) do |r|
      r.success { |user| @user = user }
      r.failure(:assign_object) { |_| render json: { errors: 'User not found' }, status: :not_found }
      r.failure(:validate) { |user| render json: { errors: user.errors }, status: :unprocessable_entity }
      r.failure(:persist) do
        render json: { errors: 'Lost connection to the database' }, status: :internal_server_error
      end
    end
  end

  def deactivate_account
    Users::DeactivateAccount.new(current_user: current_user).call(params[:id]) do |r|
      r.success { |user| @user = user }
      r.failure(:assign_object) { |_| render json: { errors: 'User not found' }, status: :not_found }
      r.failure(:same_user) do
        render json: { errors: 'You can not deactivate yourself' }, status: :unprocessable_entity
      end
    end
  end

  def activate_account
    Users::ActivateAccount.new(current_user: current_user).call(params[:id]) do |r|
      r.success { |user| @user = user }
      r.failure(:assign_object) { |_| render json: { errors: 'User not found' }, status: :not_found }
      r.failure(:same_user) do
        render json: { errors: 'You can not activate yourself' }, status: :unprocessable_entity
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:role_id)
  end
end
