require 'rails_helper'

RSpec.describe 'SessionsController', type: :request do
  describe 'POST /users/sign_in' do
    let(:user) { create(:user) }
    let(:params) { { user: { email: user.email, password: user.password } } }

    context 'when params are correct' do
      it 'returns 201' do
        post '/users/sign_in', params: params, headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status :created
      end

      it 'returns JTW token in authorization header' do
        post '/users/sign_in', params: params, headers: { 'Accept' => 'application/json' }
        expect(response.headers['Authorization']).to be_present
      end

      it 'returns valid JWT token' do
        post '/users/sign_in', params: params, headers: { 'Accept' => 'application/json' }
        decoded_token = decoded_jwt_token_from_response
        expect(decoded_token.first['sub']).to be_present
      end
    end

    context 'when login params are incorrect' do
      it 'returns unathorized status' do
        post '/users/sign_in', headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
