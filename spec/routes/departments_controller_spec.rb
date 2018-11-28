require 'rails_helper'

RSpec.describe 'Api::V1::DepartmentsController', type: :routing do
  it { expect(get: '/v1/departments').to route_to(controller: 'api/v1/departments',
    action: 'index',
    format: :json)
  }
end
