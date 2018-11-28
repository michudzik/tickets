require 'rails_helper'

RSpec.describe Tickets::Index do
  subject { described_class.new(current_user: user, params: params).call }
  let(:user) { create(:user, :admin) }
  let(:params) { {} }

  describe '#call' do
    context 'when transaction is valid' do
      it { expect(subject).to be_a Success }

      describe 'filters' do
        let!(:open_ticket) { create(:ticket) }
        let!(:support_response_ticket) { create(:ticket, :support_response) }
        let!(:user_response_ticket) { create(:ticket, :user_response) }
        let!(:closed_ticket) { create(:ticket, :closed) }
  
        it 'should show all tickets' do
          params = { filter_param: 'all' }
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to match_array [open_ticket, closed_ticket, support_response_ticket, user_response_ticket]
            end
          end
        end
  
        it 'should only show open ticket' do
          params = { filter_param: 'open' }
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [open_ticket]
            end
          end
        end
  
        it 'should only show closed ticket' do
          params = { filter_param: 'closed' }
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [closed_ticket]
            end
          end
        end
  
        it 'should only show ticket with support_response' do
          params = { filter_param: 'support_response' }
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [support_response_ticket]
            end
          end
        end
  
        it 'should only show ticket with user response' do
          params = { filter_param: 'user_response' }
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [user_response_ticket]
            end
          end
        end
      end
  
      describe 'sorting' do
        let!(:ticket1) { create(:ticket, title: 'abc') }
        let!(:ticket2) { create(:ticket, :om_department, title: 'bcd', created_at: 2.hours.ago) }
  
        it 'should sort by title_asc' do
          params = { sorted_by: 'title_asc' }
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [ticket1, ticket2]
            end
          end
        end
  
        it 'should sort by title_desc' do
          params = { sorted_by: 'title_desc' }
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [ticket2, ticket1]
            end
          end
        end
  
        it 'should sort by department_it' do
          params = { sorted_by: 'department_it' }
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [ticket1, ticket2]
            end
          end
        end
  
        it 'should sort by department_om' do
          params = { sorted_by: 'department_om' }
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [ticket1, ticket2]
            end
          end
        end
  
        it 'should order by user_name_asc' do
          params = { sorted_by: 'user_name_asc' }
          expected_array = [ticket1, ticket2].sort_by! { |ticket| ticket.user.last_name }
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq expected_array
            end
          end
        end
  
        it 'should order by user_name_desc' do
          params = { sorted_by: 'user_name_desc' }
          expected_array = [ticket1, ticket2]
          expected_array.sort_by! { |ticket| ticket.user.last_name }
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq expected_array.reverse
            end
          end
        end
  
        it 'should sort by date_desc in default' do
          subject
          expected_array = [ticket1, ticket2]
          expected_array.sort_by! { |ticket| ticket.created_at }
          expected_array = expected_array.reverse
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq expected_array
            end
          end
        end
      end
  
      context 'tickets admin' do
        let(:ticket1) { create(:ticket) }
        let(:ticket2) { create(:ticket) }
        let(:ticket3) { create(:ticket) }
        before { subject }
  
        it 'should return all tickets' do
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [ticket1, ticket2, ticket3]
            end
          end
        end
      end
  
      context 'tickets it support' do
        let(:ticket1) { create(:ticket) }
        let(:ticket2) { create(:ticket) }
        let(:ticket3) { create(:ticket, :om_department) }
        let(:it_support_user) { create(:user, :it_support) }
  
        it 'should return all tickets' do
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [ticket1, ticket2]
            end
          end
        end
      end
  
      context 'tickets om support' do
        let(:ticket1) { create(:ticket, :om_department) }
        let(:ticket2) { create(:ticket, :om_department) }
        let(:ticket3) { create(:ticket) }
        let(:om_support_user) { create(:user, :om_support) }
        before { subject }
  
        it 'should return all tickets' do
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to match_array [ticket1, ticket2]
            end
          end
        end
      end
    end

    describe '#extract_tickets' do
      before { allow_any_instance_of(Tickets::Index).to receive(:extract_tickets).and_raise ActiveRecord::ActiveRecordError }

      it 'is a failure' do
        expect(subject).to be_a Failure
      end

      it 'returns wrapped error' do
        subject do |r|
          r.failure(:extract_tickets) do |e|
            expect(e.value!).to be_a ActiveRecord::ActiveRecordError
          end
        end
      end
    end

    describe '#filter' do
      before { allow_any_instance_of(Tickets::Index).to receive(:filter).and_raise ActiveRecord::ActiveRecordError }

      it 'is a failure' do
        expect(subject).to be_a Failure
      end

      it 'returns wrapped error' do
        subject do |r|
          r.failure(:filter) do |e|
            expect(e.value!).to be_a ActiveRecord::ActiveRecordError
          end
        end
      end
    end

    describe '#sort' do
      before { allow_any_instance_of(Tickets::Index).to receive(:sort).and_raise ActiveRecord::ActiveRecordError }
      
      it 'is a failure' do
        expect(subject).to be_a Failure
      end

      it 'returns wrapped error' do
        subject do |r|
          r.failure(:sort) do |e|
            expect(e.value!).to be_a ActiveRecord::ActiveRecordError
          end
        end
      end
    end

    describe '#permission' do
      let(:user) { create(:user) }
      it { expect(subject).to be_a Failure }

      it 'returns a user' do
        subject do |r|
          r.failure(:permission) do |e|
            expect(e.value!).to eq user
          end
        end
      end
    end
  end
end
