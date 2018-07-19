require 'rails_helper'

RSpec.describe Ticket, type: :model do
    let!(:ticket) {Ticket.create(title: 'test ticket', note: 'example ticket note with some words without sense', department: 'IT', status: 'open', user: '1')}
    describe 'validations' do
        it { should validate_presence_of(:title) }
        it { should validate_presence_of(:note) }
        it { should validate_presence_of(:user) }
        it { should validate_presence_of(:department) }
        it { should belong_to(:department) }
    end

    describe 'attributes' do
        it 'should have proper attributes' do
            expect(subject.attributes).to include('title', 'note', 'status', 'user', 'department') 
        end
    end

    describe 'relations' do
        it { should belong_to(:user) }
        it { should belong_to(:department) }
        it { should belong_to(:status) }
    end

    describe '#fullticket' do
        it 'should have working #fullticket method' do
            expect(ticket.fullpost).to eq('1 test ticket example ticket note with some words without sense IT open')
        end
    end
end