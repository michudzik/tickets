require 'rails_helper'

RSpec.describe Ticket, type: :model do
    let(:admin) { create(:user, :admin) }
    let!(:user) { create(:user) }
    let!(:ticket) {Ticket.create(title: 'test ticket', note: 'example ticket note with some words without sense', department: user.department, status: 1, user_id: user.id)}
    describe 'validations' do
        it { should validate_presence_of(:title) }
        it { should validate_presence_of(:note) }
        it { should validate_presence_of(:user_id) }
        it { should validate_presence_of(:department) }
    end

    describe 'attributes' do
        it 'should have proper attributes' do
            expect(subject.attributes).to include('title', 'note', 'status', 'user_id', 'department') 
        end
    end

    describe 'relations' do
        it { should belong_to(:user) }
        it { should belong_to(:department) }
    end

    describe '#fullticket' do
        it 'should have working #fullticket method' do
            expect(ticket.fullticket).to eq('1 test ticket example ticket note with some words without sense IT open ')
        end
    end
end