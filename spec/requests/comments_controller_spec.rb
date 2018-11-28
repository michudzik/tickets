require 'rails_helper'

RSpec.describe Api::V1::CommentsController, type: :request do
  describe 'POST /v1/comments' do
    let(:user) { create(:user) }
    let(:ticket) { create(:ticket) }
    let(:params) { { comment: { body: body, ticket_id: ticket.id } } }
    let(:body) { Faker::Lorem.paragraph }

    context 'when it is successful' do
      it 'has status 200' do
        post '/v1/comments', params: params, headers: auth_headers(user)
        expect(response).to have_http_status :ok
      end

      it 'returns proper json structure' do
        post '/v1/comments', params: params, headers: auth_headers(user)
        expect(parsed_response_body).to have_key(:comment)
        expect(parsed_response_body[:comment].keys).to match_array %i[id body user ticket]
        expect(parsed_response_body[:comment][:user].keys).to match_array %i[id author email]
      end

      it 'returns proper data' do
        post '/v1/comments', params: params, headers: auth_headers(user)
        expect(parsed_response_body[:comment].values).to match_array [1, body, { id: user.id, author: user.fullname, email: user.email }, { id: ticket.id } ]
      end
    end

    context 'when validation fails' do
      let(:body) { '' }

      it 'has status 422' do
        post '/v1/comments', params: params, headers: auth_headers(user)
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'returns proper error message' do
        post '/v1/comments', params: params, headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Comment is empty'
      end
    end

    context 'when ticket is closed' do
      let(:ticket) { create(:ticket, :closed) }

      it 'has status 422' do
        post '/v1/comments', params: params, headers: auth_headers(user)
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'returns proper error message' do
        post '/v1/comments', params: params, headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'This ticket is closed'
      end
    end

    context 'when database connection is lost' do
      it 'has status 500' do
        allow(Comment).to receive(:create).and_raise ActiveRecord::ActiveRecordError
        post '/v1/comments', params: params, headers: auth_headers(user)
        expect(response).to have_http_status :internal_server_error
      end

      it 'returns proper error message' do
        allow(Comment).to receive(:create).and_raise ActiveRecord::ActiveRecordError
        post '/v1/comments', params: params, headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Lost connection to the database'
      end
    end

    context 'when ticket is not found' do
      it 'has status 404' do
        params[:comment].merge!(ticket_id: -5)
        post '/v1/comments', params: params, headers: auth_headers(user)
        expect(response).to have_http_status :not_found
      end

      it 'returns proper error message' do
        params[:comment].merge!(ticket_id: -5)
        post '/v1/comments', params: params, headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Ticket not found'
      end
    end
  end
end
