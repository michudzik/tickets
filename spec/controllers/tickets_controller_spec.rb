require 'rails_helper'

RSpec.describe TicketsController, type: :controller do

  let(:admin) { create(:user, :admin) }
  let!(:user) { create(:user) }

  describe '#index' do
    before do 
      sign_in admin
      get :index 
    end

    describe 'successful response' do
      it { expect(response).to be_successful }
      it { expect(response).to render_template('index') }
    end

    context 'tickets admin' do
      let(:ticket1) { create(:ticket) }
      let(:ticket2) { create(:ticket) }
      let(:ticket3) { create(:ticket) }

      it 'should return all tickets' do
        expect(assigns(:tickets)).to match_array([ticket1, ticket2, ticket3])
      end
    end

    context 'tickets it support' do
      let(:ticket1) { create(:ticket) }
      let(:ticket2) { create(:ticket) }
      let(:ticket3) { create(:ticket) }
      let(:it_support_user) { create(:user, :it_support) }

      it 'should return all tickets' do
        sign_out admin
        sign_in it_support_user
        expect(assigns(:tickets)).to match_array([ticket1, ticket2, ticket3])
      end
    end

    context 'tickets om support' do
      let(:ticket1) { create(:ticket, :om_department) }
      let(:ticket2) { create(:ticket, :om_department) }
      let(:ticket3) { create(:ticket, :om_department) }
      let(:om_support_user) { create(:user, :om_support) }

      it 'should return all tickets' do
        sign_out admin
        sign_in om_support_user
        expect(assigns(:tickets)).to match_array([ticket1, ticket2, ticket3])
      end
    end
  end

  describe '#show' do
    let(:ticket) { create(:ticket, user_id: user.id) }
    before do
      sign_in user
      get :show, params: { id: ticket.id } 
    end

    describe 'successful response' do
      it { expect(response).to be_successful }
      it { expect(response).to render_template('show') }
    end
  end

  describe '#new' do
    before do
      sign_in user
      get :new
    end

    describe 'successful response' do
      it { expect(response).to be_successful }
      it { expect(response).to render_template('new') }
    end

    context 'ticket' do
      it { expect(assigns(:ticket)).to be_a(Ticket) }
      it { expect(assigns(:ticket).persisted?).to eq(false) }
    end
  end

  describe '#create' do 
    before { sign_in user }
    let(:department) { create(:department) }
    let!(:status) { create(:status) }
    let(:valid_parameters) { { user_id: user.id, ticket: attributes_for(:ticket, department_id: department.id) } }
    let(:invalid_parameters) { { user_id: user.id, ticket: attributes_for(:ticket, department_id: department.id, note: 'a'*1000) } }
 
    context 'valid parameters' do
      subject { post :create, params: valid_parameters }

      it 'should redirect to user dashboard' do
        expect(subject).to redirect_to(user_dashboard_url)
      end

      it 'should redirect with a notice' do
        subject
        expect(flash[:notice]).to be_present
      end

      it 'should create new ticket' do
        expect{ subject }.to change{ Ticket.count }.by(1)
      end
    end

    context 'invalid parameters' do 
      subject { post :create, params: invalid_parameters }

      it 'should render new template' do
        expect(subject).to render_template('new')
      end

      it 'should have errors' do
        subject
        expect(assigns(:ticket).errors).to be_present
      end
    end

  end

  describe '#close' do
    before { sign_in user }
    let(:department) { create(:department) }
    let(:ticket) { create(:ticket) }
    let!(:status) { create(:status) }
    let!(:status_closed) { create(:status, :closed) }
    let(:valid_parameters) { { id: ticket.id, user_id: user.id } }
 
    context 'valid parameters' do
      subject { put :close, params: valid_parameters }

      it 'should redirect to user dashboard' do
        expect(subject).to redirect_to(user_dashboard_url)
      end

      it 'should redirect with a notice' do
        subject
        expect(flash[:notice]).to be_present
      end

      it 'should change ticket status to closed' do
        subject
        expect(ticket.reload.status.name).to eq('closed')
      end

    end
  end
end