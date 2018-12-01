require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:login_params) { { user: { email: user.email, password: user.password } } }

  describe 'GET /v1/user_dashboard' do
    context 'when it is successful' do
      let(:user) { create(:user) }

      it 'returns properly structured json' do
        get '/v1/user_dashboard', headers: auth_headers(user)
        expect(parsed_response_body.keys).to match_array %i[role email fullname tickets]
      end

      it 'returns proper data' do
        get '/v1/user_dashboard', headers: auth_headers(user)
        expect(parsed_response_body.values).to match_array [user.email, user.role.name, user.fullname, []]
      end

      it 'has status 200' do
        get '/v1/user_dashboard', headers: auth_headers(user)
        expect(response).to have_http_status :ok
      end
    end

    context 'when database connection is lost' do
      let(:user) { create(:user) }

      it 'has status 500' do
        allow_any_instance_of(User).to receive(:tickets).and_raise ActiveRecord::ActiveRecordError
        get '/v1/user_dashboard', headers: auth_headers(user)
        expect(response).to have_http_status :internal_server_error
      end

      it 'returns proper error' do
        allow_any_instance_of(User).to receive(:tickets).and_raise ActiveRecord::ActiveRecordError
        get '/v1/user_dashboard', headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Lost connection to the database'
      end
    end
  end

  describe 'GET /v1/users' do
    let(:user) { create(:user) }

    context 'when it is successful' do
      it 'returns properly structured json' do
        get '/v1/users', headers: auth_headers(user)
        expect(parsed_response_body).to have_key(:users)
        expect(parsed_response_body[:users].first.keys).to match_array %i[id fullname email role locked_at]
      end

      it 'returns proper data' do
        get '/v1/users', headers: auth_headers(user)
        expect(parsed_response_body[:users].first.values).to match_array [user.id, user.email, user.role.name, user.fullname, user.locked_at]
      end

      it 'has status 200' do
        get '/v1/users', headers: auth_headers(user)
        expect(response).to have_http_status :ok
      end
    end

    context 'when database connection is lost' do
      it 'has status 500' do
        allow_any_instance_of(Users::Index).to receive(:users).and_raise ActiveRecord::ActiveRecordError
        get '/v1/users', headers: auth_headers(user)
        expect(response).to have_http_status :internal_server_error
      end

      it 'returns proper error' do
        allow_any_instance_of(Users::Index).to receive(:users).and_raise ActiveRecord::ActiveRecordError
        get '/v1/users', headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Lost connection to the database'
      end
    end
  end

  describe 'PUT /v1/users/:id/deactivate_account' do
    let(:user) { create(:user, :admin) }
    let(:user_to_deactivate) { create(:user) }

    context 'when it is successful' do
      it 'has status 200' do
        put "/v1/users/#{user_to_deactivate.id}/deactivate_account", headers: auth_headers(user)
        expect(response).to have_http_status :ok
      end

      it 'returns properly structured json' do
        put "/v1/users/#{user_to_deactivate.id}/deactivate_account", headers: auth_headers(user)
        expect(parsed_response_body).to have_key(:user)
        expect(parsed_response_body[:user].keys).to match_array %i[id email role locked_at fullname]
      end

      it 'returns proper data' do
        put "/v1/users/#{user_to_deactivate.id}/deactivate_account", headers: auth_headers(user)
        expect(parsed_response_body[:user].values).to match_array [user_to_deactivate.id,
          user_to_deactivate.email,
          user_to_deactivate.role.name,
          user_to_deactivate.fullname,
          user_to_deactivate.reload.locked_at.as_json
        ]
      end
    end
    
    context 'when user is not found' do
      it 'has status 404' do
        put '/v1/users/-5/deactivate_account', headers: auth_headers(user)
        expect(response).to have_http_status :not_found
      end

      it 'returns proper error' do
        put '/v1/users/-5/deactivate_account', headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'User not found'
      end
    end

    context 'when user tries to deactivate himself' do
      it 'has status 422' do
        put "/v1/users/#{user.id}/deactivate_account", headers: auth_headers(user)
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'returns proper error' do
        put "/v1/users/#{user.id}/deactivate_account", headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'You can not deactivate yourself'
      end
    end
  end

  describe 'PUT /v1/users/:id/activate_account' do
    let(:user) { create(:user, :admin) }
    let(:user_to_activate) { create(:user, :locked) }

    context 'when it is successful' do
      it 'has status 200' do
        put "/v1/users/#{user_to_activate.id}/activate_account", headers: auth_headers(user)
        expect(response).to have_http_status :ok
      end

      it 'returns properly structured json' do
        put "/v1/users/#{user_to_activate.id}/activate_account", headers: auth_headers(user)
        expect(parsed_response_body).to have_key(:user)
        expect(parsed_response_body[:user].keys).to match_array %i[id email role locked_at fullname]
      end

      it 'returns proper data' do
        put "/v1/users/#{user_to_activate.id}/activate_account", headers: auth_headers(user)
        expect(parsed_response_body[:user].values).to match_array [user_to_activate.id,
          user_to_activate.email,
          user_to_activate.role.name,
          user_to_activate.fullname,
          user_to_activate.reload.locked_at.as_json
        ]
      end
    end
    
    context 'when user is not found' do
      it 'has status 404' do
        put '/v1/users/-5/activate_account', headers: auth_headers(user)
        expect(response).to have_http_status :not_found
      end

      it 'returns proper error' do
        put '/v1/users/-5/activate_account', headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'User not found'
      end
    end

    context 'when user tries to activate himself' do
      it 'has status 422' do
        put "/v1/users/#{user.id}/activate_account", headers: auth_headers(user)
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'returns proper error' do
        put "/v1/users/#{user.id}/activate_account", headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'You can not activate yourself'
      end
    end
  end

  describe 'PUT /v1/users/:id' do
    let(:user) { create(:user, :admin) }
    let(:user_to_update) { create(:user) }
    let!(:role) { create(:role, :it_support) }
    let(:params) { { user: { role_id: role.id } } }

    context 'when it is successful' do
      it 'has status 200' do
        put "/v1/users/#{user_to_update.id}", params: params, headers: auth_headers(user)
        expect(response).to have_http_status :ok
      end

      it 'returns properly structured json' do
        put "/v1/users/#{user_to_update.id}", params: params, headers: auth_headers(user)
        expect(parsed_response_body).to have_key(:user)
        expect(parsed_response_body[:user].keys).to match_array %i[id email role locked_at fullname]
      end

      it 'returns proper data' do
        put "/v1/users/#{user_to_update.id}", params: params, headers: auth_headers(user)
        expect(parsed_response_body[:user].values).to match_array [user_to_update.id,
          user_to_update.email,
          user_to_update.reload.role.name,
          user_to_update.fullname,
          user_to_update.locked_at.as_json
        ]
      end
    end

    context 'when user is not found' do
      it 'has status 404' do
        put '/v1/users/-5', params: params, headers: auth_headers(user)
        expect(response).to have_http_status :not_found
      end

      it 'returns proper error' do
        put '/v1/users/-5', params: params, headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'User not found'
      end
    end

    context 'when database connection was lost' do
      it 'has status 500' do
        allow_any_instance_of(Users::Update).to receive(:persist).and_raise ActiveRecord::ActiveRecordError
        put "/v1/users/#{user.id}", params: params, headers: auth_headers(user)
        expect(response).to have_http_status :internal_server_error
      end

      it 'returns proper error' do
        allow_any_instance_of(Users::Update).to receive(:persist).and_raise ActiveRecord::ActiveRecordError
        put "/v1/users/#{user.id}", params: params, headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to eq 'Lost connection to the database'
      end
    end

    context 'when user failed to validate' do
      it 'has status 422' do
        allow_any_instance_of(Users::Update).to receive(:validate).and_return Failure
        put "/v1/users/#{user_to_update.id}", params: params, headers: auth_headers(user)
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'returns proper error' do
        allow_any_instance_of(Users::Update).to receive(:validate).and_return Failure
        put "/v1/users/#{user_to_update.id}", params: params, headers: auth_headers(user)
        expect(parsed_response_body[:errors]).to be_a Hash
      end
    end
  end
end
