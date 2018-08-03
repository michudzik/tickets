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
    it { should validate_length_of(:title).is_at_most(50) }
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
    it { should have_many(:comments)}
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
        expect(ticket.status.name).to eq('user_response')
      end
    end

    describe '#support_response' do
      let!(:status) { create(:status, :support_response) }

      it 'should change ticket status to support_response' do
        ticket.support_response
        expect(ticket.status.name).to eq('support_response')
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

    describe '::find_related_tickets' do
      let!(:ticket_it) { create(:ticket) }
      let!(:ticket_om) { create(:ticket, :om_department) } 
      context 'it' do
        it 'should return it ticket' do
          user = create(:user, :it_support)
          expect(Ticket.find_related_tickets(user)).to include(ticket_it)
          expect(Ticket.find_related_tickets(user)).not_to include(ticket_om)
        end
      end
      context 'om' do
        it 'should return om ticket' do
          user = create(:user, :om_support)
          expect(Ticket.find_related_tickets(user)).to include(ticket_om)
          expect(Ticket.find_related_tickets(user)).not_to include(ticket_it)
        end
      end
      context 'admin' do
        it 'should return both tickets' do
          user = create(:user, :admin)
          expect(Ticket.find_related_tickets(user)).to include(ticket_it, ticket_om)
        end
      end
    end

    describe '::filter_tickets' do
      let!(:open_ticket) { create(:ticket) }
      let!(:support_response_ticket) { create(:ticket, :support_response) }
      let!(:user_response_ticket) { create(:ticket, :user_response) }
      let!(:closed_ticket) { create(:ticket, :closed) }

      it 'should return open ticket' do
        expect(Ticket.filter_tickets('open')).to include(open_ticket)
        expect(Ticket.filter_tickets('open')).not_to include(support_response_ticket, user_response_ticket, closed_ticket)
      end

      it 'should return closed ticket' do
        expect(Ticket.filter_tickets('closed')).to include(closed_ticket)
        expect(Ticket.filter_tickets('closed')).not_to include(support_response_ticket, user_response_ticket, open_ticket)
      end

      it 'should return user_response ticket' do
        expect(Ticket.filter_tickets('user_response')).to include(user_response_ticket)
        expect(Ticket.filter_tickets('user_response')).not_to include(support_response_ticket, open_ticket, closed_ticket)
      end

      it 'should return support_response ticket' do
        expect(Ticket.filter_tickets('support_response')).to include(support_response_ticket)
        expect(Ticket.filter_tickets('support_response')).not_to include(open_ticket, user_response_ticket, closed_ticket)
      end
    end

    describe '::sort_tickets' do
      let(:ticket1) { create(:ticket, title: 'abc') }
      let(:ticket2) { create(:ticket, :om_department, title: 'bcd', created_at: 2.hours.ago) }
      before do
        Ticket.destroy_all
        ticket1
        ticket2
      end
      
      it 'should sort by title_asc' do
        expect(Ticket.sort_tickets('title_asc')).to eq([ticket1, ticket2])
      end

      it 'should sort by title_desc' do
        expect(Ticket.sort_tickets('title_desc')).to eq([ticket2, ticket1])
      end

      it 'should sort by department_it' do
        expect(Ticket.sort_tickets('department_it')).to eq([ticket1, ticket2])
      end

      it 'should sort by department_om' do
        expect(Ticket.sort_tickets('department_om')).to eq([ticket2, ticket1])
      end

      it 'should order by user_name_asc' do
        expected_array = [ticket1, ticket2].sort_by! { |ticket| ticket.user.last_name }
        expect(Ticket.sort_tickets('user_name_asc')).to eq(expected_array)
      end

      it 'should order by user_name_desc' do
        expected_array = [ticket1, ticket2]
        expected_array.sort_by! { |ticket| ticket.user.last_name }
        expect(Ticket.sort_tickets('user_name_desc')).to eq([expected_array[1], expected_array[0]])
      end
    end

  end

  describe 'callbacks' do
    let(:ticket)             { create(:ticket) }
    let!(:closed)            { create(:status, :closed) }
    let!(:user_response)     { create(:status, :user_response) }
    let!(:support_response)  { create(:status, :support_response) }

    it 'should set status to open' do
        expect(ticket.status.name).to eq('open')
    end
  end              

  describe 'attachments' do
    it 'is valid  ' do
      subject.uploads.attach(io: File.open(fixture_path + '/testimage.jpg'), filename: 'attachment.jpg', content_type: 'image/jpg')
      expect(subject.uploads).to be_attached
    end
  end

  describe 'scopes' do

    context 'department' do
      let(:ticket_it) { create(:ticket) }
      let(:ticket_om) { create(:ticket, :om_department) }

      it 'should have it_department scope' do
        expect(Ticket.it_department).to include(ticket_it)
        expect(Ticket.it_department).not_to include(ticket_om)
      end

      it 'should have om_department scope' do
        expect(Ticket.om_department).to include(ticket_om)
        expect(Ticket.om_department).not_to include(ticket_it)
      end
    end

    context 'status filters' do
      let(:ticket_open) { create(:ticket) }
      let(:ticket_closed) { create(:ticket, :closed) }
      let(:ticket_user_response) { create(:ticket, :user_response) }
      let(:ticket_support_response) { create(:ticket, :support_response) }

      it 'should return open ticket' do
        expect(Ticket.filtered_by_status_open).to include(ticket_open)
        expect(Ticket.filtered_by_status_open).not_to include(ticket_closed, ticket_support_response, ticket_user_response)
      end

      it 'should return user_response ticket' do
        expect(Ticket.filtered_by_status_user_response).to include(ticket_user_response)
        expect(Ticket.filtered_by_status_user_response).not_to include(ticket_open, ticket_closed, ticket_support_response)
      end

      it 'should return support_response ticket' do
        expect(Ticket.filtered_by_status_support_response).to include(ticket_support_response)
        expect(Ticket.filtered_by_status_support_response).not_to include(ticket_open, ticket_closed, ticket_user_response)
      end

      it 'should return closed ticket' do
        expect(Ticket.filtered_by_status_closed).to include(ticket_closed)
        expect(Ticket.filtered_by_status_closed).not_to include(ticket_open, ticket_support_response, ticket_user_response)
      end
    end

    context 'ordering' do
      let(:ticket1) { create(:ticket, title: 'abcdef') }
      let(:ticket2) { create(:ticket, :om_department, title: 'bcdefgh') }
      let(:ticket3) { create(:ticket, created_at: 2.hours.ago) }
      let(:ticket4) { create(:ticket, created_at: 3.hours.ago) }

      it 'should order by title asc' do
        expected_array = [ticket1, ticket2]
        expect(Ticket.ordered_by_title_asc).to eq(expected_array)
      end

      it 'should order by title desc' do
        expected_array = [ticket2, ticket1]
        expect(Ticket.ordered_by_title_desc).to eq(expected_array)
      end

      it 'should order by department_name asc' do
        expected_array = [ticket1, ticket2]
        expect(Ticket.ordered_by_department_it).to eq(expected_array)
      end

      it 'should order by department_name desc' do
        expected_array = [ticket2, ticket1]
        expect(Ticket.ordered_by_department_om).to eq(expected_array)
      end

      it 'should order by date desc' do
        expected_array = [ticket3, ticket4]
        expect(Ticket.ordered_by_date).to eq(expected_array)
      end

    end
  end

end