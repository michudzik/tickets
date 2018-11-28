require 'rails_helper'

RSpec.describe Users::Index do
  subject { described_class.new(params: { filter_param: filter_param, sorted_by: sorted_by, page: 10, number: 10 }).call }

  describe '#call' do
    let(:filter_param) { 'unlocked' }
    let(:sorted_by) { 'last_name_desc' }

    context 'when transaction is valid' do
      it { expect(subject).to be_a Success }

      describe 'sorting' do
        let(:user1) { create(:user, last_name: 'abc', email: 'abc@abc.com') }
        let(:user2) { create(:user, last_name: 'bcd', email: 'bcd@abc.com') }
        
        it 'should sort by last_name_asc' do
          sorted_by ='last_name_asc'
          expected_array = [user1, user2]
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq expected_array
            end
          end
        end
  
        it 'should sort by last_name_desc' do
          sorted_by ='last_name_desc'
          expected_array = [user2, user1]
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq expected_array
            end
          end
        end
  
        it 'should sort by email_asc' do
          sorted_by ='email_asc'
          expected_array = [user1, user2]
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq expected_array
            end
          end
        end
  
        it 'should sort by email_desc' do
          sorted_by ='email_desc'
          expected_array = [user2, user1]
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq expected_array
            end
          end
        end
      end
  
      describe 'filter' do
        let!(:locked_user) { create(:user, :locked) }
        let!(:unlocked_user) { create(:user) }
  
        it 'should return locked users' do
          filter_param = 'locked'
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to include locked_user
              expect(monad.value!).not_to include unlocked_user
            end
          end
        end
  
        it 'should return unlocked users' do
          filter_param = 'unlocked'
          subject do |r|
            r.success do |monad|
              expect(monad.value!).not_to include locked_user
              expect(monad.value!).to include unlocked_user
            end
          end
        end
  
        it 'should return all users' do
          filter_param = 'all'
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to match_array [locked_user, unlocked_user]
            end
          end
        end
      end
  
      context 'users' do
        let!(:user_1) { create(:user) }
        let!(:user_2) { create(:user) }
        it 'should return all users' do
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [user_1, user_2]
            end
          end
        end
      end
    end

    describe '#users' do
      it 'is a failure' do
        allow(User).to receive(:all).and_raise ActiveRecord::ActiveRecordError
        expect(subject).to be_a Failure
      end
    end

    describe '#filter' do
      it 'is a failure' do
        allow(User).to receive(:filter_users).and_raise ActiveRecord::ActiveRecordError
        expect(subject).to be_a Failure
      end
    end

    describe '#sort' do
      it 'is a failure' do
        allow(User).to receive(:sort_users).and_raise ActiveRecord::ActiveRecordError
        expect(subject).to be_a Failure
      end
    end
  end
end
