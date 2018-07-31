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
    let(:admin) { create(:user, :admin) }
    before do 
      sign_in admin
      get :index
    end

    describe 'successful response' do
      it { expect(response).to be_successful }
      it { expect(response).to render_template('index') }
    end

    context 'users' do
      let!(:user_1) { create(:user) }
      let!(:user_2) { create(:user) }

      it 'should return all users' do
        expect(assigns(:users)).to match_array([user_1, user_2])
      end
    end
    
  end

  describe '#update' do
    let(:admin)             { create(:user, :admin) }
    let(:user)              { create(:user) }
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
        expect(user.reload.role_id).to eq(3)
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