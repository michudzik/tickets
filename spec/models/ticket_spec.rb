require 'rails_helper'

RSpec.describe Ticket, type: :model do

  let(:admin) { create(:user, :admin) }
  let!(:user) { create(:user) }
  let!(:ticket) { Ticket.create() }
    
  describe 'validations' do
      it { should validate_presence_of(:title) }
      it { should validate_presence_of(:note) }
      it { should validate_presence_of(:department) }
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

    describe '#fullticket' do
      let!(:ticket) { create(:ticket) }
      it 'should have working #fullticket method' do
        expect(ticket.fullticket).to eq(" #{ticket.user_id} #{ticket.title} #{ticket.note} #{ticket.department} #{ticket.status} ")
      end
    end

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

    describe 'attachments' do
      it 'is valid  ' do
        subject.uploads.attach(io: File.open(fixture_path + '/testimage.jpg'), filename: 'attachment.jpg', content_type: 'image/jpg')
        expect(subject.uploads).to be_attached
      end
    end
end