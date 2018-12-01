class Api::V1::RolesController < Api::V1::ApiController
  def index
    Roles::List.new.call do |r|
      r.success { |roles| @roles = roles }
      r.failure(:extract_values) do
        render json: { errors: 'Lost connection to the database' }, status: :internal_server_error
      end
    end
  end
end
