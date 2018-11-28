class Api::V1::DepartmentsController < Api::V1::ApiController
  def index
    Departments::List.new.call do |r|
      r.success { |departments| @departments = departments }
      r.failure(:extract_values) { |_| render json: { errors: 'Lost connection to the database' }, status: :internal_server_error }
    end
  end
end
