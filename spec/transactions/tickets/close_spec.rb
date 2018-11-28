require 'rails_helper'

RSpec.describe Tickets::Close do
  subject { described_class.new.call(ticket_id) }
  let(:ticket) { create(:ticket) }
  let(:ticket_id) { ticket.id }
  let!(:closed) { create(:status, :closed) }
  
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

      it 'closes the ticket' do
        subject
        expect(ticket.reload.status.name).to eq 'closed'
      end
    end

    describe '#find_object' do
      let(:ticket_id) { -5 }

      it { expect(subject).to be_a Failure }

      it 'returns wrapped error' do
        subject do |r|
          r.failure(:find_object) do |e|
            expect(e.value!).to be_a ActiveRecord::RecordNotFound            
          end
        end        
      end
    end

    describe '#change_status' do
      before { allow_any_instance_of(Ticket).to receive(:update).and_raise(ActiveRecord::ActiveRecordError) }

      it { expect(subject).to be_a Failure }

      it 'returns wrapped error' do
        subject do |r|
          r.failure(:change_status) do |e|
            expect(e.value!).to be_a ActiveRecord::ActiveRecordError 
          end
        end
      end
    end
  end
end
