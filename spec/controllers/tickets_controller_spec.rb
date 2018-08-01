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
    let(:department) { create(:department) }
    let(:ticket) { create(:ticket) }
    let!(:status) { create(:status) }
    let!(:status_closed) { create(:status, :closed) }
    let(:valid_parameters) { { id: ticket.id, user_id: user.id } }
 
    context 'user' do
      before { sign_in user }
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

    context 'support' do
      let(:it) { create(:user, :it_support) }
      let(:om) { create(:user, :om_support) }
      let(:admin) { create(:user, :admin) }
      subject { put :close, params: valid_parameters }

      context 'it_support' do
        before { sign_in it }
        it 'should redirect to tickets index' do
          expect(subject).to redirect_to(show_tickets_path)
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

      context 'om_support' do
        before { sign_in om }
        it 'should redirect to tickets index' do
          expect(subject).to redirect_to(show_tickets_path)
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

      context 'admin' do
        before { sign_in admin }
        it 'should redirect to tickets index' do
          expect(subject).to redirect_to(show_tickets_path)
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

  describe '#search' do
    let(:ticket1) { create(:ticket, title: 'abc', note: 'abc') }
    let(:ticket2) { create(:ticket, :om_deparment, title: 'cde', note: 'cde') }
    let(:ticket3) { create(:ticket, :om_deparment, title: 'abc', note: 'abc') }
    let(:ticket4) { create(:ticket, title: 'cde', note: 'cde') }
    subject { get :search, params: { query: 'a' } }
    
    describe 'successful response' do
      let(:user) { create(:user, :admin) }
      before do
       sign_in user
       subject
     end

      it 'should get a successful response' do
        expect(response).to be_successful
      end

      it 'should render search engine template' do
        expect(response).to render_template('search')
      end
    end

    context 'user' do
      let(:user) { create(:user) }
      before { sign_in user }

      it 'should redirect to user\'s dashboard' do
        expect(subject).to redirect_to(user_dashboard_path)
      end

      it 'should redirect with a notice' do
        subject
        expect(flash[:alert]).to be_present
      end
    end

    context 'admin' do
      let(:admin) { create(:user, :admin) }
      subject { get :search, params: { query: 'a'} }

    end

    context 'it_support' do
    end

    context 'om_support' do
    end
  end


end