require 'rails_helper'

RSpec.describe CommentsController, type: :controller do

  describe '#create' do
    let(:ticket)              { create(:ticket) }
    let(:user)                { create(:user, :it_support) }
    let(:valid_attributes)    { { comment: { user_id: ticket.user.id, ticket_id: ticket.id, body: 'a'*20 } } }
    let(:invalid_attributes)  { { comment: { user_id: ticket.user.id, ticket_id: ticket.id, body: nil } } }
    let!(:closed)             { create(:status, :closed) }
    let!(:user_response)      { create(:status, :user_response) }
    let!(:support_response)   { create(:status, :support_response) }

    context 'valid parameters' do
      subject { post :create, params: valid_attributes }
      it 'should create comment' do
        sign_in ticket.user
        expect{subject}.to change{Comment.count}.by(1)
      end
    end

    context 'invalid parameters' do 
      subject { post :create, params: invalid_attributes }
      it 'should redirect to ticket' do
        sign_in ticket.user
        expect(subject).to redirect_to(ticket_path(ticket.id))
      end

      it 'should redirect with an alert' do
        sign_in ticket.user
        subject
        expect(flash[:alert]).to be_present
      end
    end

    context 'additional actions' do
      subject { post :create, params: valid_attributes }
      it 'should not create comment when ticket is closed' do
        ticket.status = closed
        ticket.save
        sign_in ticket.user
        expect{subject}.not_to change{Comment.count}
      end

      it 'should change ticket status to user response' do
        sign_in ticket.user
        subject
        expect(ticket.reload.status.name).to eq('user_response')
      end

      it 'should change ticket status to support response' do
        sign_in user
        post :create, params: { comment: { user_id: user.id, ticket_id: ticket.id, body: 'a'*20 } }
        expect(ticket.reload.status.name).to eq('support_response')
      end
    end
  end
end