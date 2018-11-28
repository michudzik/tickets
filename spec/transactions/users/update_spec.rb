require 'rails_helper'

RSpec.describe Users::Update do
  subject { described_class.new(params: params).call(id) }
  let!(:user) { create(:user) }
  let(:id) { user.id }
  let(:role) { create(:role, :it_support) }
  let(:role_id) { role.id }
  let(:params) { { role_id: role_id } }
  
  describe '#call' do
    context 'when transaction is valid' do
      it { expect(subject).to be_a Success }

      it 'returns a user' do
        subject do |r|
          r.success do |monad|
            expect(monad.value!).to eq user
          end
        end
      end

      it 'changes the role of our user' do
        subject
        expect(user.reload.role).to eq role
      end
    end

    describe '#assign_object' do
      let(:id) { -5 }

      it { expect(subject).to be_a Failure }

      it 'returns a wrapped error' do
        subject do |r|
          r.failure(:assign_object) do |e|
            expect(e.value!).to be_a ActiveRecord::RecordNotFound
          end
        end
      end
    end
    
    describe '#validate' do
      let(:role_id) { nil }

      it { expect(subject).to be_a Failure }

      it 'returns a user' do
        subject do |r|
          r.failure(:validate) do |e|
            expect(e.value!).to eq user
          end
        end
      end
    end

    describe '#persist' do
      before { allow_any_instance_of(User).to receive(:save!).and_raise ActiveRecord::ActiveRecordError }

      it { expect(subject).to be_a Failure }

      it 'returns wrapped error' do
        subject do |r|
          r.failure(:persist) do |e|
            expect(e.value!).to be_a ActiveRecord::ActiveRecordError
          end
        end
      end
    end
  end
end
