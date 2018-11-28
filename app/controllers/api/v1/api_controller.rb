class Api::V1::ApiController < ActionController::API
  before_action :authenticate_user!
end
