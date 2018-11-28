require 'rails_helper'

RSpec.describe Api::V1::RolesController, type: :request do
  describe 'GET /v1/roles' do
    let(:user) { create(:user, :admin) }

    context 'when it is successful' do
      it 'has status 200' do
        get '/v1/roles', headers: auth_headers(user)
        expect(response).to have_http_status :ok
      end

      it 'returns proper json structure' do
        get '/v1/roles', headers: auth_headers(user)
        expect(parsed_response_body).to have_key(:roles)
        expect(parsed_response_body[:roles].first.keys).to match_array %i[id name]
      end

      it 'returns proper data' do
        get '/v1/roles', headers: auth_headers(user)
        expect(parsed_response_body[:roles].first.values).to match_array [1, 'Admin']
      end
    end

    context 'when database connection is lost' do
      it 'has status 500' do
        allow(Role).to receive(:all).and_raise ActiveRecord::ActiveRecordError
        get '/v1/roles', headers: auth_headers(user)
        expect(response).to have_http_status :internal_server_error
      end

      it 'returns proper error message' do
        allow(Role).to receive(:all).and_raise ActiveRecord::ActiveRecordError
        get '/v1/roles', headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Lost connection to the database'
      end
    end
  end
end
