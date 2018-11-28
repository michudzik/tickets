require 'rails_helper'

RSpec.describe Tickets::Show do
  subject { described_class.new(current_user: user).call(ticket_id) }
  let(:user) { create(:user) }
  let(:ticket) { create(:ticket, user: user) }
  let(:ticket_id) { ticket.id }
  
  describe '#call' do
    context 'when transaction is valid' do
      it { expect(subject).to be_a Success }

      it 'returns a ticket' do
        subject do |r|
          r.success do |monad|
            expect(monad.value!).to eq ticket
          end
        end
      end
    end

    describe '#assign_object' do
      let(:ticket_id) { -5 }

      it { expect(subject).to be_a Failure }

      it 'returns a wrapped error' do
        subject do |r|
          r.failure(:assign_object) do |e|
            expect(e.value!).to be_a ActiveRecord::RecordNotFound
          end
        end
      end
    end

    describe '#related_to_ticket' do
      let(:ticket) { create(:ticket) }
      let(:ticket_id) { ticket.id }
      
      it { expect(subject).to be_a Failure }

      it 'returns a ticket' do
        subject do |r|
          r.failure(:related_to_ticket) do |e|
            expect(e.value!).to eq ticket
          end
        end
      end
    end
  end
end
