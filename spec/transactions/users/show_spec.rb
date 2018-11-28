require 'rails_helper'

RSpec.describe Users::Show do
  subject { described_class.new(current_user: user, params: {}).call }
  
  let(:user) { create(:user) }
  let(:ticket) { create(:ticket, user: user) }
  
  describe '#call' do
    context 'when transaction is valid' do
      it { expect(subject).to be_a Success }

      it 'returns user tickets' do
        subject do |r|
          r.success do |monad|
            expect(monad.value!).to eq [ticket]
          end
        end
      end
    end

    describe '#extract_tickets' do
      it 'is a failure' do
        allow_any_instance_of(User).to receive(:tickets).and_raise ActiveRecord::ActiveRecordError
        expect(subject).to be_a Failure
      end

      it 'returns wrapped error' do
        allow_any_instance_of(User).to receive(:tickets).and_raise ActiveRecord::ActiveRecordError
        subject do |r|
          r.failure(:extract_tickets) do |e|
            expect(e.value!).to be_a ActiveRecord::ActiveRecordError
          end
        end
      end
    end
  end
end
