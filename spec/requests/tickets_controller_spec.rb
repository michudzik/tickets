require 'rails_helper'

RSpec.describe TicketsController, type: :request do
  describe 'POST /v1/tickets' do
    let(:user) { create(:user) }
    let(:department) { create(:department) }
    let(:params) { { ticket: { department_id: department.id, title: title, note: note } } }
    let!(:status) { create(:status) }
    let(:title) { Faker::Lorem.sentence }
    let(:note) { Faker::Lorem.paragraph }

    context 'when it is successful' do
      it 'has status 200' do
        post '/v1/tickets', params: params, headers: auth_headers(user)
        expect(response).to have_http_status :ok
      end

      it 'returns proper json structure' do
        post '/v1/tickets', params: params, headers: auth_headers(user)
        expect(parsed_response_body).to have_key(:ticket)
        expect(parsed_response_body[:ticket].keys).to match_array %i[id title author department status]
      end

      it 'returns proper data' do
        post '/v1/tickets', params: params, headers: auth_headers(user)
        expect(parsed_response_body[:ticket].values).to match_array [1, title, user.fullname, 'IT', 'open']
      end
    end

    context 'when database connection is lost' do
      it 'has status 500' do
        allow_any_instance_of(Tickets::Create).to receive(:create_ticket).and_raise ActiveRecord::ActiveRecordError
        post '/v1/tickets', params: params, headers: auth_headers(user)
        expect(response).to have_http_status :internal_server_error
      end

      it 'has proper error message' do
        allow_any_instance_of(Tickets::Create).to receive(:create_ticket).and_raise ActiveRecord::ActiveRecordError
        post '/v1/tickets', params: params, headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Lost connection to the database'
      end
    end
    
    context 'when validation failed' do
      let(:note) { '' }

      it 'has status 422' do
        post '/v1/tickets', params: params, headers: auth_headers(user)
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'returns proper error message' do
        post '/v1/tickets', params: params, headers: auth_headers(user)
        expect(parsed_response_body).to have_key(:errors)
        expect(parsed_response_body[:errors][:note].join).to eq 'must be filled'
      end
    end
  end

  describe 'GET /v1/tickets/:id' do
    let(:user) { create(:user, :admin) }
    let!(:ticket) { create(:ticket) }

    context 'when it is successful' do
      it 'has status 200' do
        get "/v1/tickets/#{ticket.id}", headers: auth_headers(user)
        expect(response).to have_http_status :ok
      end

      it 'returns proper json structure' do
        get "/v1/tickets/#{ticket.id}", headers: auth_headers(user)
        expect(parsed_response_body.keys).to match_array %i[id title note created_at updated_at department status user comments]
      end

      it 'returns proper data' do
        get "/v1/tickets/#{ticket.id}", headers: auth_headers(user)
        expect(parsed_response_body.values).to match_array [
          ticket.id,
          ticket.title,
          ticket.note,
          ticket.created_at.as_json,
          ticket.updated_at.as_json,
          ticket.department.name,
          ticket.status.name,
          { id: ticket.user.id, author: ticket.user.fullname, role: ticket.user.role.name },
          []
        ]
      end
    end

    context 'when user is not related to ticket' do
      let(:user) { create(:user) }

      it 'has status 403' do
        get "/v1/tickets/#{ticket.id}", headers: auth_headers(user)
        expect(response).to have_http_status :forbidden
      end

      it 'returns proper error message' do
        get "/v1/tickets/#{ticket.id}", headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Forbidden access'
      end
    end

    context 'when ticket is not found' do
      it 'has status 404' do
        get '/v1/tickets/-5', headers: auth_headers(user)
        expect(response).to have_http_status :not_found
      end

      it 'returns proper error message' do
        get '/v1/tickets/-5', headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Ticket not found'
      end
    end

    context 'when database connection is lost' do
      it 'has status 500' do
        allow_any_instance_of(Ticket).to receive(:comments).and_raise ActiveRecord::ActiveRecordError
        get "/v1/tickets/#{ticket.id}", headers: auth_headers(user)
        expect(response).to have_http_status :internal_server_error
      end

      it 'returns proper error message' do
        allow_any_instance_of(Ticket).to receive(:comments).and_raise ActiveRecord::ActiveRecordError
        get "/v1/tickets/#{ticket.id}", headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Lost connection to the database'
      end
    end
  end

  describe 'GET /v1/tickets' do
    let(:user) { create(:user, :admin) }

    context 'when it is successful' do
      let!(:ticket) { create(:ticket) }

      it 'has status 200' do
        get '/v1/tickets', headers: auth_headers(user)
        expect(response).to have_http_status :ok
      end

      it 'returns proper json structure' do
        get '/v1/tickets', headers: auth_headers(user)
        expect(parsed_response_body).to have_key :tickets
        expect(parsed_response_body[:tickets].first.keys).to match_array %i[id title department status updated_at author]
      end

      it 'returns proper data' do
        get '/v1/tickets', headers: auth_headers(user)
        expect(parsed_response_body[:tickets].first.values).to match_array [
          ticket.id,
          ticket.title,
          ticket.department.name,
          ticket.status.name,
          ticket.updated_at.as_json,
          ticket.user.fullname
        ]
      end
    end

    context 'when database connection is lost' do
      it 'has status 500' do
        allow_any_instance_of(Tickets::Index).to receive(:filter).and_raise ActiveRecord::ActiveRecordError
        get '/v1/tickets', headers: auth_headers(user)
        expect(response).to have_http_status :internal_server_error
      end

      it 'returns proper error message' do
        allow_any_instance_of(Tickets::Index).to receive(:filter).and_raise ActiveRecord::ActiveRecordError
        get '/v1/tickets', headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Lost connection to the database'
      end
    end

    context 'when unauthorized user tries to access the index' do
      let(:user) { create(:user) }

      it 'has status 403' do
        get '/v1/tickets', headers: auth_headers(user)
        expect(response).to have_http_status :forbidden
      end

      it 'returns proper error message' do
        get '/v1/tickets', headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Forbidden access'
      end
    end
  end

  describe 'GET /v1/search' do
    let(:user) { create(:user, :admin) }
    let!(:ticket) { create(:ticket, title: 'Title') }
    let(:params) { { query: 'Title'} }

    context 'when it is successful' do
      it 'has status 200' do
        get '/v1/search', params: params, headers: auth_headers(user)
        expect(response).to have_http_status :ok
      end

      it 'returns properly structured json' do
        get '/v1/search', params: params, headers: auth_headers(user)
        expect(parsed_response_body).to have_key(:tickets)
        expect(parsed_response_body[:tickets].first.keys).to match_array %i[id title department status updated_at author]
      end

      it 'returns proper data' do
        get '/v1/search', params: params, headers: auth_headers(user)
        expect(parsed_response_body[:tickets].first.values).to match_array [
          ticket.id,
          ticket.title,
          ticket.department.name,
          ticket.status.name,
          ticket.updated_at.as_json,
          ticket.user.fullname
        ]
      end
    end

    context 'when unauthorized user tries to access the search engine' do
      let(:user) { create(:user) }

      it 'has status 403' do
        get '/v1/search', headers: auth_headers(user)
        expect(response).to have_http_status :forbidden
      end

      it 'returns proper error' do
        get '/v1/search', headers: auth_headers(user)
      end
    end

    context 'when database connection is lost' do
      it 'has status 500' do
        allow_any_instance_of(Tickets::Search).to receive(:filter).and_raise ActiveRecord::ActiveRecordError
        get '/v1/search', headers: auth_headers(user)
        expect(response).to have_http_status :internal_server_error
      end

      it 'returns proper error' do
        allow_any_instance_of(Tickets::Search).to receive(:filter).and_raise ActiveRecord::ActiveRecordError
        get '/v1/search', headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Lost connection to the database'
      end
    end
  end

  describe 'PUT /v1/tickets/:id/close' do
    let(:user) { create(:user, :admin) }
    let(:ticket) { create(:ticket) }
    let!(:status) { create(:status, :closed) }

    context 'when it is successful' do
      it 'has status 200' do
        put "/v1/tickets/#{ticket.id}/close", headers: auth_headers(user)
        expect(response).to have_http_status :ok
      end

      it 'returns properly structured json' do
        put "/v1/tickets/#{ticket.id}/close", headers: auth_headers(user)
        expect(parsed_response_body).to have_key(:ticket)
        expect(parsed_response_body[:ticket].keys).to match_array %i[id title note status department]
      end

      it 'returns proper data' do
        put "/v1/tickets/#{ticket.id}/close", headers: auth_headers(user)
        expect(parsed_response_body).to have_key(:ticket)
        expect(parsed_response_body[:ticket].values).to match_array [ticket.id, ticket.note, ticket.title, ticket.reload.status.name, ticket.department.name]
      end
    end
    
    context 'when ticket is not found' do
      it 'has status 404' do
        put '/v1/tickets/-5/close', headers: auth_headers(user)
        expect(response).to have_http_status :not_found
      end

      it 'returns a proper error' do
        put '/v1/tickets/-5/close', headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Ticket not found'
      end
    end

    context 'when database connection is lost' do
      it 'has status 500' do
        allow_any_instance_of(Ticket).to receive(:update).and_raise ActiveRecord::ActiveRecordError
        put "/v1/tickets/#{ticket.id}/close", headers: auth_headers(user)
        expect(response).to have_http_status :internal_server_error
      end

      it 'returns a proper error' do
        allow_any_instance_of(Ticket).to receive(:update).and_raise ActiveRecord::ActiveRecordError
        put "/v1/tickets/#{ticket.id}/close", headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Lost connection to the database'
      end
    end
  end
end
