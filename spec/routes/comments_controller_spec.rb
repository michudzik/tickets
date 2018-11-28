require 'rails_helper'

RSpec.describe 'Api::V1::CommentsController', type: :routing do
  it { expect(post: '/v1/comments').to route_to(controller: 'api/v1/comments',
    action: 'create',
    format: :json)
  }
end
