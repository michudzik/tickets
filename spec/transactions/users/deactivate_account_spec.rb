require 'rails_helper'

RSpec.describe Users::DeactivateAccount do
  subject { described_class.new(current_user: user).call(id) }
  let(:user) { create(:user, :admin) }
  let(:user_to_deactivate) { create(:user) }
  let(:id) { user_to_deactivate.id }

  describe '#call' do

    context 'when transaction is valid' do
      it { expect(subject).to be_a Success }

      it 'returns a user' do
        subject do |r|
          r.success do |monad|
            expect(monad.value!).to eq user_to_deactivate
          end
        end
      end

      it 'deactivates the user' do
        subject
        expect(user_to_deactivate.reload.access_locked?).to eq true
      end
    end

    describe '#assign_object' do
      let(:id) { -5 }

      it { expect(subject).to be_a Failure }

      it 'does not deactivate the user' do
        subject
        expect(user_to_deactivate.reload.access_locked?).to eq false
      end

      it 'returns wrapped error' do
        subject do |r|
          r.failure(:assign_object) do |e|
            expect(e.value!).to be_a ActiveRecord::RecordNotFound
          end
        end
      end
    end

    describe '#same_user' do
      let(:id) { user.id }

      it { expect(subject).to be_a Failure }

      it 'does not deactivate the user' do
        subject
        expect(user_to_deactivate.reload.access_locked?).to eq false
      end

      it 'returns a user' do
        subject do |r|
          r.failure(:same_user) do |e|
            expect(e.value!).to be_a user
          end
        end
      end
    end

    describe '#deactivate' do
      it 'is a failure' do
        allow_any_instance_of(User).to receive(:lock_access!).and_raise ActiveRecord::ActiveRecordError
        expect(subject).to be_a Failure
      end

      it 'does not deactivate the user' do
        allow_any_instance_of(User).to receive(:lock_access!).and_raise ActiveRecord::ActiveRecordError
        subject
        expect(user_to_deactivate.reload.access_locked?).to eq false
      end

      it 'returns wrapped error' do
        allow_any_instance_of(User).to receive(:lock_access!).and_raise ActiveRecord::ActiveRecordError
        subject do |r|
          r.failure(:deactivate) do |e|
            expect(e.value!).to be_a ActiveRecord::ActiveRecordError
          end
        end
      end
    end
  end
end
