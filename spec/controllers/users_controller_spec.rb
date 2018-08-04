require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  
  describe '#show' do
    describe 'successful response' do
      let(:user) { create(:user) }
      before do
        sign_in user
        get :show, params: { id: user.id } 
      end
      it { expect(response).to be_successful }
      it { expect(response).to render_template('show') }
    end
  end

  describe '#index' do
    let(:admin) { create(:user, :admin, last_name: 'cde', email: 'cde@cde.com') }
    subject { get :index }
    before { sign_in admin }

    describe 'successful response' do
      before { subject }
      it { expect(response).to be_successful }
      it { expect(response).to render_template('index') }
    end

    describe 'sorting' do
      let(:user1) { create(:user, last_name: 'abc', email: 'abc@abc.com') }
      let(:user2) { create(:user, last_name: 'bcd', email: 'bcd@abc.com') }

      it 'should sort by last_name_asc' do
        get :index, params: { sorted_by: 'last_name_asc' }
        expected_array = [user1, user2, admin]
        expect(assigns(:users)).to eq(expected_array)
      end

      it 'should sort by last_name_desc' do
        get :index, params: { sorted_by: 'last_name_desc' }
        expected_array = [admin, user2, user1]
        expect(assigns(:users)).to eq(expected_array)
      end

      it 'should sort by email_asc' do
        get :index, params: { sorted_by: 'email_asc' }
        expected_array = [user1, user2, admin]
        expect(assigns(:users)).to eq(expected_array)
      end

      it 'should sort by email_desc' do
        get :index, params: { sorted_by: 'email_desc' }
        expected_array = [admin, user2, user1]
        expect(assigns(:users)).to eq(expected_array)
      end
    end

    describe 'filter' do
      let!(:locked_user) { create(:user) }
      let!(:unlocked_user) { create(:user) }
      before { locked_user.lock_access! }

      it 'should return locked users' do
        get :index, params: { filter_param: 'locked' }
        users = assigns(:users)
        expect(users).to include(locked_user)
        expect(users).not_to include(unlocked_user)
      end

      it 'should return unlocked users' do
        get :index, params: { filter_param: 'unlocked' }
        users = assigns(:users)
        expect(users).to include(unlocked_user)
        expect(users).not_to include(locked_user)
      end

      it 'should return all users' do
        get :index, params: { filter_param: 'all' }
        users = assigns(:users)
        expect(users).to match_array([admin, locked_user, unlocked_user])
      end
    end

    context 'users' do
      let!(:user_1) { create(:user) }
      let!(:user_2) { create(:user) }
      before { subject }
      it 'should return all users' do
        expect(assigns(:users)).to match_array([admin, user_1, user_2])
      end
    end
    
  end

  describe '#update' do
    let(:admin)             { create(:user, :admin) }
    let(:user)              { create(:user, :it_support) }
    let(:user_role)         { create(:role) }
    let(:valid_params)      { { id: user.id, user: { role_id: user_role.id } } }
    let(:invalid_params)    { { id: user.id, user: { role_id: nil } } }

    context 'valid params' do
       subject  { patch :update, params: valid_params }
       before   { sign_in admin }

      it 'should redirect to users index' do
        expect(subject).to redirect_to(users_url)
      end

      it 'should change user role' do
        subject
        expect(user.reload.role.name).to eq('user')
      end
    end

    context 'invalid params' do
      subject   { patch :update, params: invalid_params }
      before    { sign_in admin }

      it 'should render index template' do
        expect(subject).to render_template('index')
      end

      it 'should not change role_id' do
        user_id = user.role_id
        subject
        expect(user.reload.role_id).not_to eq(nil)
      end
    end
  end

  describe '#deactivate_user' do
    let(:admin) { create(:user, :admin) }
    let(:user)  { create(:user) }
    before { sign_in admin }

    it 'should deactivate user' do
      put :deactivate_account, params: { id: user.id }
      expect(user.reload.access_locked?).to eq(true)
    end

    context 'same user' do
      subject { put :deactivate_account, params: { id: admin.id } }
      it 'should redirect to index when admin wants to deactivate himself' do
        expect(subject).to redirect_to(users_url)
      end

      it 'should redirect with an alert' do
        subject
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe '#activate_user' do
    let(:admin) { create(:user, :admin) }
    let(:user)  { create(:user) }
    subject { put :activate_account, params: { id: user.id } } 
    before { sign_in admin }

    it 'should activate user' do
      subject
      expect(user.reload.access_locked?).to eq(false)
    end

    context 'same user' do
      subject { put :activate_account, params: { id: admin.id } }
      it 'should redirect to index when admin wants to deactivate himself' do
        expect(subject).to redirect_to(users_url)
      end

      it 'should redirect with an alert' do
        subject
        expect(flash[:alert]).to be_present
      end
    end
  end

end