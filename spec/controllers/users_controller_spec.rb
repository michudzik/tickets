require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe '#show' do
    describe 'successful response' do
      subject { get :show, params: { id: user.id } }
      let(:user) { create(:user) }
      before { sign_in user }

      it 'is successful' do
        subject
        expect(response).to be_successful
      end

      it 'renders correct template' do
        expect(subject).to render_template('show')
      end

      context 'when database connection was lost during ticket extraction' do
        before { allow_any_instance_of(User).to receive(:tickets).and_raise ActiveRecord::ActiveRecordError }

        it 'redirects to user path' do
          expect(subject).to redirect_to user_path(user.id)
        end

        it 'redirects with an alert' do
          subject
          expect(flash[:alert]).to eq 'Lost connection to the database'
        end
      end
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
    
    context 'when database connection was lost during filtering' do
      subject { get :index, params: { filter_param: 'unlocked' } }
      before { allow_any_instance_of(Users::Index).to receive(:filter).and_raise ActiveRecord::ActiveRecordError }

      it 'redirects to users index' do
        expect(subject).to redirect_to users_path
      end

      it 'redirects with an alert' do
        subject
        expect(flash[:alert]).to eq 'Lost connection to the database'
      end
    end

    context 'when database connection was lost during sorting' do
      subject { get :index, params: { sort_by: 'last_name_desc' } }
      before { allow_any_instance_of(Users::Index).to receive(:sort).and_raise ActiveRecord::ActiveRecordError }

      it 'redirects to users index' do
        expect(subject).to redirect_to users_path
      end

      it 'redirects with an alert' do
        subject
        expect(flash[:alert]).to eq 'Lost connection to the database'
      end
    end
  end

  describe '#update' do
    let(:admin)             { create(:user, :admin) }
    let(:user)              { create(:user, :it_support) }
    let(:user_role)         { create(:role) }
    let(:valid_params)      { { id: user.id, user: { role_id: user_role.id } } }
    let(:invalid_params)    { { id: user.id, user: { role_id: -5 } } }
    before   { sign_in admin }

    context 'valid params' do
      subject  { patch :update, params: valid_params }

      it 'should redirect to users index' do
        expect(subject).to redirect_to(users_url)
      end

      it 'redirects with a notice' do
        subject
        expect(flash[:notice]).to be_present
      end
    end

    context 'when user is not found' do
      subject { patch :update, params: { id: -5, user: { role_id: -5 } } }

      it 'redirects to users index' do
        expect(subject).to redirect_to users_path        
      end

      it 'redirects with an alert' do
        subject
        expect(flash[:alert]).to eq 'User not found'
      end
    end

    context 'when validation went wrong' do
      before { allow_any_instance_of(Users::Update).to receive(:validate).and_return(false) }
      subject  { patch :update, params: valid_params }

      it 'renders index' do
        expect(subject).to render_template :index
      end
    end

    context 'when connection to the database was lost' do
      before { allow_any_instance_of(Users::Update).to receive(:persist).and_raise(ActiveRecord::ActiveRecordError) }
      subject  { patch :update, params: valid_params }

      it 'redirects to users index' do
        expect(subject).to redirect_to users_path
      end

      it 'redirects with an alert' do
        subject
        expect(flash[:alert]).to eq 'Lost connection to database'
      end
    end
  end

  describe '#deactivate_user' do
    let(:admin) { create(:user, :admin) }
    let(:user)  { create(:user) }
    subject { put :deactivate_account, params: { id: user.id } }
    before { sign_in admin }

    it 'redirects to users path' do
      expect(subject).to redirect_to users_path
    end

    context 'when user is not found' do
      subject { put :deactivate_account, params: { id: -5 } }

      it 'redirects to users url' do
        expect(subject).to redirect_to users_path
      end

      it 'redirects with an alert' do
        subject
        expect(flash[:alert]).to eq 'User not found'
      end
    end

    context 'same user' do
      subject { put :deactivate_account, params: { id: admin.id } }

      it 'should redirect to index when admin wants to deactivate himself' do
        expect(subject).to redirect_to(users_url)
      end

      it 'should redirect with an alert' do
        subject
        expect(flash[:alert]).to eq 'You can not deactivate yourself'
      end
    end
  end

  describe '#activate_user' do
    let(:admin) { create(:user, :admin) }
    let(:user)  { create(:user) }
    subject { put :activate_account, params: { id: user.id } } 
    before { sign_in admin }

    it 'redirects to users path' do
      expect(subject).to redirect_to users_path
    end

    context 'when user is not found' do
      subject { put :activate_account, params: { id: -5 } }

      it 'redirects to users index' do
        expect(subject).to redirect_to users_path
      end

      it 'redirects with an alert' do
        subject
        expect(flash[:alert]).to eq 'User not found'
      end
    end

    context 'same user' do
      subject { put :activate_account, params: { id: admin.id } }

      it 'should redirect to index when admin wants to deactivate himself' do
        expect(subject).to redirect_to(users_url)
      end

      it 'should redirect with an alert' do
        subject
        expect(flash[:alert]).to eq 'You can not activate yourself'
      end
    end
  end
end
