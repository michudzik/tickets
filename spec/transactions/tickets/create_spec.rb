require 'rails_helper'

RSpec.describe Tickets::Create do
  subject { described_class.new(current_user: user).call(params) }
  let(:user) { create(:user) }
  let(:department) { create(:department) }
  let(:department_id) { department.id }
  let!(:status) { create(:status) }
  let(:params) { { title: 'a'*50, note: 'a'*300, department_id: department_id } }

  describe '#call' do
    context 'when transaction is valid' do
      it { expect(subject).to be_a Success }

      it 'returns a ticket' do
        subject do |r|
          r.success do |monad|
            expect(monad.value!).to be_a Ticket
          end
        end
      end

      it 'creates new ticket' do
        expect{ subject }.to change{ Ticket.count }.by 1
      end
    end

    describe '#validate' do
      let(:params) { { title: 'a'*501, note: 'a', department_id: department_id } }

      it { expect(subject).to be_a Failure }

      it 'returns wrapped validation errors' do
        subject do |r|
          r.failure(:validate) do |e|
            expect(e.value!.errors).to have_key(:title)
            expect(e.value!.errors[:title]).to eq 'size cannot be greater than 50'
          end
        end
      end
    end

    describe '#create_ticket' do
      before { allow_any_instance_of(Tickets::Create).to receive(:create_ticket).and_raise(ActiveRecord::ActiveRecordError) }

      it { expect(subject).to be_a Failure }

      it 'returns wrapped error' do
        subject do |r|
          r.success do |monad|
            expect(monad.value!).to be_a ActiveRecord::ActiveRecordError
          end
        end
      end
    end

    describe '#notify_users_via_slack' do
      before { allow_any_instance_of(Slack::TicketsCreate).to receive(:pick_emails).and_raise(ActiveRecord::ActiveRecordError) }

      it { expect(subject).to be_a Failure }

      it 'returns ticket wrapped in failure' do
        subject do |r|
          r.failure(:notify_users_via_slack) do |e|
            expect(e.value!).to be_a Tickets
          end
        end  
      end
    end
  end
end
