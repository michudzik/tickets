require 'rails_helper'

RSpec.describe Tickets::Search do
  subject { described_class.new(current_user: user, params: 'blabla').call }
  let(:user) { create(:user, :admin) }

  describe '#call' do
    context 'when transaction is valid' do
      let!(:ticket1) { create(:ticket, title: 'abc', note: 'abc') }
      let!(:ticket2) { create(:ticket, :om_department, title: 'cde', note: 'cde') }
      let!(:ticket3) { create(:ticket, :om_department, title: 'abc', note: 'abc') }
      let!(:ticket4) { create(:ticket, title: 'cde', note: 'cde') }
      it { expect(subject).to be_a Success }
  
      context 'admin' do
        let(:user) { create(:user, :admin) }

        it 'should return ticket1 and ticket3' do
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [ticket1, ticket3]
            end
          end
        end
  
        it 'should not return ticket2 and ticket4' do
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [ticket2, ticket4]
            end
          end
        end
      end
  
      context 'it_support' do
        let(:user) { create(:user, :it_support) }
  
        it 'should return ticket1' do
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [ticket1]
            end
          end
        end
  
        it 'should not return ticket1, ticket2 and ticket4' do
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [ticket2, ticket3, ticket4]
            end
          end
        end
      end
  
      context 'om_support' do
        let(:user) { create(:user, :om_support) }
  
        it 'should return ticket3' do
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [ticket3]
            end
          end
        end
  
        it 'should not return ticket2 and ticket4' do
          subject do |r|
            r.success do |monad|
              expect(monad.value!).to eq [ticket1, ticket2, ticket4]
            end
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
