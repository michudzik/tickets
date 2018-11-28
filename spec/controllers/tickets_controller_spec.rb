require 'rails_helper'

RSpec.describe TicketsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let!(:user) { create(:user) }

  describe '#index' do
    context 'when admin is signed in' do
      before { sign_in admin }
      subject { get :index }
  
      describe 'successful response' do
        before { subject }
        it { expect(response).to be_successful }
        it { expect(response).to render_template('index') }
      end

      context 'when database connection is lost during extraction' do
        before { allow(Ticket).to receive(:find_related_tickets).and_raise ActiveRecord::ActiveRecordError }

        it 'redirects to user dashboard' do
          expect(subject).to redirect_to user_dashboard_path
        end

        it 'redirects with an alert' do
          subject
          expect(flash[:alert]).to eq 'Lost connection to the database'
        end
      end

      context 'when database connection is lost during filtering' do
        before { allow(Ticket).to receive(:filter_tickets).and_raise ActiveRecord::ActiveRecordError }

        it 'redirects to user dashboard' do
          expect(subject).to redirect_to user_dashboard_path
        end

        it 'redirects with an alert' do
          subject
          expect(flash[:alert]).to eq 'Lost connection to the database'
        end
      end

      context 'when database connection is lost during sorting' do
        before { allow(Ticket).to receive(:sort_tickets).and_raise ActiveRecord::ActiveRecordError }

        it 'redirects to user dashboard' do
          expect(subject).to redirect_to user_dashboard_path
        end

        it 'redirects with an alert' do
          subject
          expect(flash[:alert]).to eq 'Lost connection to the database'
        end
      end
    end

    context 'when user is signed in' do
      before { sign_in user }
      subject { get :index }

      it 'redirect to user dashboard path' do
        expect(subject).to redirect_to user_dashboard_path
      end

      it 'redirects with an alert' do
        subject
        expect(flash[:alert]).to eq 'Forbidden access'
      end
    end
  end

  describe '#show' do
    let(:ticket) { create(:ticket, user_id: user.id) }
    subject { get :show, params: { id: ticket.id } }
    
    describe 'successful response' do
      before { sign_in user }

      it 'is successful' do
        expect(response).to be_successful
      end

      it { expect(subject).to render_template('show') }
    end

    context 'when database connection is lost while fetching comments' do
      before { sign_in user }
      
      it 'redirects to user dashboard' do
        allow_any_instance_of(Ticket).to receive(:comments).and_raise ActiveRecord::ActiveRecordError
        expect(subject).to redirect_to user_dashboard_path
      end

      it 'redirects with an alert' do
        allow_any_instance_of(Ticket).to receive(:comments).and_raise ActiveRecord::ActiveRecordError
        subject
        expect(flash[:alert]).to eq 'Lost connection to the database'
      end
    end

    context 'when user is not related to ticket' do
      let(:user_2) { create(:user) }
      before { sign_in user_2 }
      
      it 'redirect to user dashboard' do
        expect(subject).to redirect_to user_dashboard_path
      end

      it 'redirects with an alert' do
        subject
        expect(flash[:alert]).to eq 'Forbidden access'
      end
    end
  end

  describe '#new' do
    subject { get :new }
    before { sign_in user }

    describe 'successful response' do
      it 'is successful' do
        subject
        expect(response).to be_successful
      end

      it 'renders correct template' do
        expect(subject).to render_template('new')
      end
    end

    context 'when connection to the database was lost while fetching departments' do
      before { allow(Department).to receive(:all).and_raise ActiveRecord::ActiveRecordError }

      it 'redirects to user dashboard' do
        expect(subject).to redirect_to user_dashboard_path
      end

      it 'redirects with an alert' do
        subject
        expect(flash[:alert]).to eq 'Lost connection to the database'
      end
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
        expect(flash[:notice]).to match 'New ticket has been reported'
      end
    end

    context 'when ticket failed to validate' do
      subject { post :create, params: valid_parameters }
      before { allow_any_instance_of(Dry::Validation::Result).to receive(:success?).and_return false }
      
      it 'renders new template' do
        expect(subject).to render_template :new
      end
    end

    context 'when database problems occured' do
      subject { post :create, params: valid_parameters }
      before { allow_any_instance_of(Tickets::Create).to receive(:create_ticket).and_raise ActiveRecord::ActiveRecordError }

      it 'redirects to user dashboard' do
        expect(subject).to redirect_to user_dashboard_path
      end

      it 'redirects with an alert' do
        subject
        expect(flash[:alert]).to eq 'Lost connection to the database'
      end
    end
  end

  describe '#close' do
    let(:department) { create(:department) }
    let(:ticket) { create(:ticket) }
    let!(:status) { create(:status) }
    let!(:status_closed) { create(:status, :closed) }
    let(:valid_parameters) { { id: ticket.id, user_id: user.id } }
 
    context 'when ticket is not found' do
      before { sign_in user }
      subject { put :close, params: { id: -5, user_id: user.id } }

      it 'redirects to users dashboard' do
        expect(subject).to redirect_to user_dashboard_path
      end

      it 'redirects with an alert' do
        subject
        expect(flash[:alert]).to eq 'Ticket not found'
      end
    end

    context 'when database problems occured while updating the status' do
      before { sign_in user }
      subject { put :close, params: { id: ticket.id, user_id: user.id } }

      it 'redirects to user dashboard' do
        allow_any_instance_of(Ticket).to receive(:update).and_raise ActiveRecord::ActiveRecordError
        expect(subject).to redirect_to user_dashboard_path
      end

      it 'redirects with an alert' do
        allow_any_instance_of(Ticket).to receive(:update).and_raise ActiveRecord::ActiveRecordError
        subject
        expect(flash[:alert]).to eq 'Lost connection to the database'        
      end
    end

    context 'user' do
      before { sign_in user }
      subject { put :close, params: valid_parameters }

      it 'should redirect to user dashboard' do
        expect(subject).to redirect_to(user_dashboard_url)
      end

      it 'should redirect with a notice' do
        subject
        expect(flash[:notice]).to eq 'Ticket closed'
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
          expect(flash[:notice]).to eq 'Ticket closed'
        end
      end

      context 'om_support' do
        before { sign_in om }

        it 'redirects to tickets index' do
          expect(subject).to redirect_to(show_tickets_path)
        end

        it 'redirects with a notice' do
          subject
          expect(flash[:notice]).to eq 'Ticket closed'
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
    let(:ticket2) { create(:ticket, :om_department, title: 'cde', note: 'cde') }
    let(:ticket3) { create(:ticket, :om_department, title: 'abc', note: 'abc') }
    let(:ticket4) { create(:ticket, title: 'cde', note: 'cde') }
    subject { get :search, params: { query: 'a' } }
    
    context 'when normal user tries to access search tool' do
      let(:user) { create(:user) }
      before { sign_in user }

      it 'redirects to user dashboard' do
        expect(subject).to redirect_to user_dashboard_path
      end

      it 'redrects with an alert' do
        subject
        expect(flash[:alert]).to eq 'Forbidden access'
      end
    end

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
  end
end
