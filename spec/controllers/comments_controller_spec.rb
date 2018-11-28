require 'rails_helper'

RSpec.describe CommentsController, type: :controller do

  describe '#create' do
    let(:ticket)              { create(:ticket) }
    let(:user)                { create(:user, :it_support) }
    let(:valid_attributes)    { { comment: { user_id: ticket.user.id, ticket_id: ticket.id, body: 'a'*20 } } }
    let(:invalid_attributes)  { { comment: { user_id: ticket.user.id, ticket_id: ticket.id, body: nil } } }

    context 'when everything is ok' do
      subject { post :create, params: valid_attributes }
      before { sign_in user }

      it 'redirects to ticket path' do
        expect(subject).to redirect_to ticket_path(ticket.id)
      end

      it 'redirects with a notice' do
        subject
        expect(flash[:notice]).to match 'Comment created'
      end
    end

    context 'when ticket is not found' do
      subject { post :create, params: { comment: { user_id: ticket.user.id, ticket_id: -5, body: 'a'*20 } } }
      before { sign_in user }

      it 'redirects to user dashboard path' do
        expect(subject).to redirect_to user_dashboard_path
      end

      it 'redirects with an alert' do
        subject
        expect(flash[:alert]).to eq 'Ticket not found'
      end
    end

    context 'when ticket is closed' do
      let(:ticket) { create(:ticket, :closed) }
      subject { post :create, params: { comment: { user_id: ticket.user.id, ticket_id: ticket.id, body: 'a'*20 } } }
      before { sign_in user }

      it 'redirects to ticket path' do
        expect(subject).to redirect_to ticket_path(ticket.id)
      end

      it 'redirects with an alert' do
        subject
        expect(flash[:alert]).to eq 'This ticket is closed'
      end
    end

    context 'when validation failed' do
      subject { post :create, params: { comment: { user_id: ticket.user.id, ticket_id: ticket.id, body: '' } } }
      before { sign_in user }

      it 'redirects to ticket path' do
        expect(subject).to redirect_to ticket_path(ticket.id)
      end

      it 'redirects with an alert' do
        subject
        expect(flash[:alert]).to eq 'Comment is empty'
      end
    end

    context 'when database connection was lost' do
      subject { post :create, params: { comment: { user_id: ticket.user.id, ticket_id: ticket.id, body: 'a'*20 } } }
      before { sign_in user }

      it 'redirects to root path' do
        allow(Comment).to receive(:create).and_raise ActiveRecord::ActiveRecordError
        expect(subject).to redirect_to root_path
      end

      it 'redirects with an alert' do
        allow(Comment).to receive(:create).and_raise ActiveRecord::ActiveRecordError
        subject
        expect(flash[:alert]).to eq 'Lost connection to the database'
      end
    end
  end
end
