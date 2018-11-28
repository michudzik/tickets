require 'rails_helper'

RSpec.describe TicketPresenter, type: :presenter do
  let(:ticket) { create(:ticket, user: user, status: status, department: department, note: 
    "Ticket\nNote") }
  let(:department) { create(:department, :om) }
  let(:status) { create(:status, :user_response) }
  let(:user) { create(:user, first_name: 'First', last_name: 'Last') }

  describe 'methods' do
    subject { described_class.new(ticket) }

    describe '#department_name' do
      it 'returns department\'s name' do
        expect(subject.department_name).to eq "OM"
      end
    end

    describe '#created_at' do
      it 'returns properly formatted created at time' do
        expect(subject.created_at).to eq ticket.created_at.strftime("%k:%M %d-%m-%Y")
      end
    end

    describe '#last_response' do
      it 'returns ticket created at time when ticket has no comments' do
        expect(subject.last_response).to eq ticket.created_at.strftime("%k:%M %d-%m-%Y")
      end

      it 'returns ticket last comment created at time if there are any' do
        comment = create(:comment, ticket: ticket, user: user)
        expect(subject.last_response).to eq comment.created_at.strftime("%Y.%m.%d %H:%M")
      end
    end

    describe '#status' do
      it 'returns properly formatted status name' do
        expect(subject.status).to eq 'User response'
      end
    end

    describe '#author' do
      it 'returns username' do
        expect(subject.author).to eq 'First Last'
      end
    end

    describe '#note' do
      it 'returns properly formatted note' do
        expect(subject.note).to eq 'Ticket<br />Note'
      end
    end
  end
end
