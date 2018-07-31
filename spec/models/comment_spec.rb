require 'rails_helper'

RSpec.describe Comment, type: :model do

  describe 'attributes' do
    it 'should have proper attributes' do
      expect(subject.attributes).to include('user_id', 'ticket_id', 'body')
    end
  end

	describe 'validations' do
		it { should validate_presence_of(:body) }
	end

  describe 'relations' do
    it { should belong_to(:user) }
    it { should belong_to(:ticket) }
  end

  describe 'attachments' do
    it 'is valid  ' do
      subject.uploads.attach(io: File.open(fixture_path + '/testimage.jpg'), filename: 'attachment.jpg', content_type: 'image/jpg')
      expect(subject.uploads).to be_attached
    end
  end

  describe 'methods' do
    describe '#update_ticket_status!' do
      let(:admin) { create(:user, :admin) }
      let(:ticket) { create(:ticket) }
      let(:comment) { create(:comment, ticket_id: ticket.id) }

      context 'user response' do
        let!(:user_response) { create(:status, :user_response) }
        it 'should have user response status' do
          comment.update_ticket_status!(user: ticket.user, ticket: ticket)
          expect(ticket.status.name).to eq('user_response')
        end
      end

      context 'support response' do
        let!(:support_response) { create(:status, :support_response) }
        it 'should have support response status' do
          comment.update_ticket_status!(user: admin, ticket: ticket)
          expect(ticket.status.name).to eq('support_response')
        end
      end

    end
  end

end