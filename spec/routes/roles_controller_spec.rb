require 'rails_helper'

RSpec.describe 'Api::V1::RolesController', type: :routing do
  it { expect(get: '/v1/roles').to route_to(controller: 'api/v1/roles',
    action: 'index',
    format: :json)
  }
end
