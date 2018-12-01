require 'rails_helper'

RSpec.describe Api::V1::DepartmentsController, type: :request do
  describe 'GET /v1/departments' do
    let(:user) { create(:user, :admin) }

    context 'when it is successful' do
      it 'returns status 200' do
        get '/v1/departments', headers: auth_headers(user)
        expect(response).to have_http_status :ok
      end

      it 'returns proper json structure' do
        it_department = create(:department)
        get '/v1/departments', headers: auth_headers(user)
        expect(parsed_response_body).to have_key(:departments)
        expect(parsed_response_body[:departments].first.keys).to match_array %i[id name]
      end

      it 'returns proper data' do
        it_department = create(:department)
        get '/v1/departments', headers: auth_headers(user)
        expect(parsed_response_body[:departments].first.values).to match_array [it_department.id, it_department.name]
      end
    end

    context 'when database connection is lost' do
      it 'has status 500' do
        allow(Department).to receive(:all).and_raise ActiveRecord::ActiveRecordError
        get '/v1/departments', headers: auth_headers(user)
        expect(response).to have_http_status :internal_server_error
      end

      it 'returns proper error message' do
        allow(Department).to receive(:all).and_raise ActiveRecord::ActiveRecordError
        get '/v1/departments', headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Lost connection to the database'
      end
    end
  end
end
