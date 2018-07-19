require 'rails_helper'

RSpec.describe Ticket, type: :model do
    describe 'validations' do
        it { should validate_presence_of(:title) }
        it { should validate_presence_of(:note) }
        it { should validate_presence_of(:user_id) }
        it { should validate_presence_of(:department) }
        it { should belong_to(:department) }
    end

    describe 'attributes' do
        it 'should have proper attributes' do
            expect(subject.attributes).to include('title', 'note', 'status', 'user_id', 'department') 
        end
    end

    describe 'relations' do
        it { should belong_to(:user) }
        it { should belong_to(:department) }
        it { should belong_to(:status) }
    end

    describe '#fullticket' do
        let!(:ticket) {Ticket.create(title: 'test ticket', note: 'example ticket note with some words without sense', department: 'IT', status: 'open', user_id: 1)}
        it 'should have working #fullticket method' do
            expect(ticket.fullticket).to eq('1 test ticket example ticket note with some words without sense IT open ')
        end
    end

    describe '#closed?' do
        let(:ticket) { create(:ticket) }
        let(:status) { create(:status, :closed) }

        it 'should return false' do
            expect(ticket.closed?).to eq(false)
        end

        it 'should return true' do
            ticket.status = status
            expect(ticket.closed?).to eq(true)
        end
    end

    describe 'callbacks' do
        let(:ticket)             { create(:ticket, status_id: nil) }
        let!(:open)              { create(:status, :open) }
        let!(:closed)            { create(:status, :closed) }
        let!(:user_response)     { create(:status, :user_response) }
        let!(:support_response)  { create(:status, :support_response) }

        it 'should set status to open' do
            expect(ticket.status.status).to eq('open')
        end
    end
end