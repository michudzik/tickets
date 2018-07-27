require 'rails_helper'

RSpec.describe CommentsController, type: :controller do

  describe '#create' do
    let(:ticket)              { create(:ticket) }
    let(:user)                { create(:user, :it_support) }
    let(:valid_attributes)    { { comment: { user_id: ticket.user.id, ticket_id: ticket.id, body: 'a'*20 } } }
    let!(:closed)             { create(:status, :closed) }
    let!(:user_response)      { create(:status, :user_response) }
    let!(:support_response)   { create(:status, :support_response) }
    subject                   { post :create, params: valid_attributes }

    context 'valid parameters' do
      it 'should create comment' do
        sign_in ticket.user
        expect{subject}.to change{Comment.count}.by(1)
      end
    end

    context 'additional actions' do

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