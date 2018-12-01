require 'rails_helper'

RSpec.describe 'RegistrationsController', type: :request do
  describe 'POST /users' do
    context 'when user is unauthenticated' do
      let(:user) { build(:user) }
      let(:params) { { user: { first_name: user.first_name, last_name: user.last_name, email: user.email, password: user.password, password_confirmation: user.password } } }
  
      it 'returns 201' do
        post '/users', params: params, headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status :created
      end
  
      it 'returns a new user' do
        post '/users', params: params, headers: { 'Accept' => 'application/json' }
        expect(parsed_response_body.keys).to match_array %i[id email first_name last_name created_at updated_at role_id]
      end

      it 'creates new user' do
        expect{ post '/users', params: params, headers: { 'Accept' => 'application/json' } }.to change{ User.count }.by 1
      end
    end
  
    context 'when user already exists' do
      let(:user) { create(:user) }
      let(:params) { { user: { first_name: user.first_name, last_name: user.last_name, email: user.email, password: user.password, password_confirmation: user.password } } }

      it 'returns 422' do
        post '/users', params: params, headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status :unprocessable_entity
      end
  
      it 'returns validation errors' do
        post '/users', params: params, headers: { 'Accept' => 'application/json' }
        expect(parsed_response_body[:errors][:email].join).to eq 'has already been taken'
      end
    end
  end
end
