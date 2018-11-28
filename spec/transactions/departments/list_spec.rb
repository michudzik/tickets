require 'rails_helper'

RSpec.describe Departments::List do
  subject { described_class.new.call }
  let!(:department) { create(:department) }
  
  describe '#call' do
    context 'when transaction is successful' do
      it { expect(subject).to be_a Success }

      it 'returns an array of name and ids' do
        subject do |r|
          r.success do |monad|
            expect(monad.value!).to eq [department.name, department.id]
          end
        end
      end
    end

    describe '#extract_values' do
      it 'is a failure' do
        allow(Department).to receive(:all).and_raise ActiveRecord::ActiveRecordError
        expect(subject).to be_a Failure
      end

      it 'returns a wrapped error' do
        allow(Department).to receive(:all).and_raise ActiveRecord::ActiveRecordError
        subject do |r|
          r.failure(:extract_values) do |e|
            expect(e.value!).to be_a ActiveRecord::ActiveRecordError\
          end
        end
      end
    end
  end
end
