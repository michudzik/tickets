require 'rails_helper'

RSpec.describe Roles::List do
  subject { described_class.new.call }
  let!(:role) { create(:role) }
  describe '#call' do
    context 'when transaction is successful' do
      it { expect(subject).to be_a Success }

      it 'returns properly formatted array of roles' do
        subject do |r|
          r.success do |monad|
            expect(monad.value!).to eq [role.name.humanize, role.id]
          end
        end
      end
    end

    describe '#extract_values' do
      it 'is a failure' do
        allow(Role).to receive(:all).and_raise ActiveRecord::ActiveRecordError
        expect(subject).to be_a Failure
      end

      it 'returns wrapped error' do
        allow(Role).to receive(:all).and_raise ActiveRecord::ActiveRecordError
        subject do |r|
          r.failure(:extract_values) do |e|
            expect(e.value!).to be_a ActiveRecord::ActiveRecordError
          end
        end
      end
    end
  end
end
