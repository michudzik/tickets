require 'rails_helper'

RSpec.describe 'Api::V1::UsersController', type: :routing do
  it { expect(get: '/v1/user_dashboard').to route_to(controller: 'api/v1/users',
    action: 'show',
    format: :json)
  }
  it { expect(get: '/v1/users').to route_to(controller: 'api/v1/users',
    action: 'index',
    format: :json)
  }
  it { expect(put: '/v1/users/1/deactivate_account').to route_to(controller: 'api/v1/users',
    action: 'deactivate_account',
    format: :json,
    id: '1')
  }
  it { expect(put: '/v1/users/1/activate_account').to route_to(controller: 'api/v1/users',
    action: 'activate_account',
    format: :json,
    id: '1')
  }
  it { expect(put: '/v1/users/1').to route_to(controller: 'api/v1/users',
    action: 'update',
    format: :json,
    id: '1')
  }
  it { expect(patch: '/v1/users/1').to route_to(controller: 'api/v1/users',
    action: 'update',
    format: :json,
    id: '1')
  }
end
