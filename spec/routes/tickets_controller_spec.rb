require 'rails_helper'

RSpec.describe 'Api::V1::TicketsController', type: :routing do
  it { expect(get: '/v1/tickets/1').to route_to(controller: 'api/v1/tickets',
    action: 'show',
    format: :json,
    id: '1')
  }
  it { expect(get: '/v1/search').to route_to(controller: 'api/v1/tickets',
    action: 'search',
    format: :json)
  }
  it { expect(get: '/v1/tickets').to route_to(controller: 'api/v1/tickets',
    action: 'index',
    format: :json)
  }
  it { expect(post: '/v1/tickets').to route_to(controller: 'api/v1/tickets',
    action: 'create',
    format: :json)
  }
  it { expect(put: '/v1/tickets/1/close').to route_to(controller: 'api/v1/tickets',
    action: 'close',
    format: :json,
    id: '1')
  }
end
