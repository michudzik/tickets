require 'rails_helper'

RSpec.describe Ticket, type: :model do

  let(:admin) { create(:user, :admin) }
  let!(:user) { create(:user) }
  let!(:ticket) { Ticket.create() }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:note) }
    it { should validate_presence_of(:department) }
    it { should validate_length_of(:note).is_at_most(500) }
    it { should validate_length_of(:title).is_at_most(30) }
  end

  describe 'attributes' do
    it 'should have proper attributes' do
      expect(subject.attributes).to include('title', 'note', 'status_id', 'user_id', 'department_id') 
    end
  end

  describe 'relations' do
    it { should belong_to(:user) }
    it { should belong_to(:department) }
    it { should belong_to(:status) }
  end

  describe 'methods' do

    let(:ticket) { create(:ticket) }

    describe '#closed?' do
      let(:status) { create(:status, :closed) }

      it 'should return false' do
        expect(ticket.closed?).to eq(false)
      end

      it 'should return true' do
        ticket.status = status
        expect(ticket.closed?).to eq(true)
      end
    end

    describe '#user_response' do
      let!(:status) { create(:status, :user_response) }

      it 'should change ticket status to user_response' do
        ticket.user_response
        expect(ticket.status.status).to eq('user_response')
      end
    end

    describe '#support_response' do
      let!(:status) { create(:status, :support_response) }

      it 'should change ticket status to support_response' do
        ticket.support_response
        expect(ticket.status.status).to eq('support_response')
      end
    end

    describe '#related_to_ticket?' do
      let(:ticket_it) { create(:ticket) }
      let(:ticket_om) { create(:ticket, :om_department) }

      context 'it_support' do
        let(:user) { create(:user, :it_support) }

        it 'should return true' do
          expect(ticket_it.related_to_ticket?(user)).to eq(true)
        end

        it 'should return false' do
          expect(ticket_om.related_to_ticket?(user)).to eq(false)
        end
      end

      context 'om_support' do
        let(:user) { create(:user, :om_support) }

        it 'should return true' do
          expect(ticket_om.related_to_ticket?(user)).to eq(true)
        end

        it 'should return false' do
          expect(ticket_it.related_to_ticket?(user)).to eq(false)
        end
      end

      context 'admin' do 
        let(:user) { create(:user, :admin) }

        it 'should return true' do
          expect(ticket_it.related_to_ticket?(user)).to eq(true)
        end

        it 'should return true' do
          expect(ticket_om.related_to_ticket?(user)).to eq(true)
        end
      end
    end
  end

  describe 'callbacks' do
    let(:ticket)             { create(:ticket) }
    let!(:closed)            { create(:status, :closed) }
    let!(:user_response)     { create(:status, :user_response) }
    let!(:support_response)  { create(:status, :support_response) }

    it 'should set status to open' do
      expect(ticket.status.status).to eq('open')
    end
  end

end