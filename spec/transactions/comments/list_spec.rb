require 'rails_helper'

RSpec.describe Comments::List do
  subject { described_class.new.call(ticket) }
  let(:ticket) { create(:ticket) }
  let!(:comment) { create(:comment, ticket: ticket, created_at: DateTime.now) }
  let!(:comment_1) { create(:comment, ticket: ticket, created_at: DateTime.now + 1.hour) }

  describe '#call' do
    context 'when transaction is successful' do
      it { expect(subject).to be_a Success }

      it 'returns an array of comments' do
        subject do |r|
          r.success do |monad|
            expect(e.value!).to match_array [comment_1, comment]
          end
        end
      end

      it 'orders them by created at' do
        subject do |r|
          r.success do |monad|
            expect(e.value!).to eq [comment_1, comment]
          end
        end
      end
    end

    describe '#extract_comments' do
      it 'is a failure' do
        allow_any_instance_of(Ticket).to receive(:comments).and_raise ActiveRecord::ActiveRecordError
        expect(subject).to be_a Failure
      end

      it 'returns wrapped error' do
        allow_any_instance_of(Ticket).to receive(:comments).and_raise ActiveRecord::ActiveRecordError
        subject do |r|
          r.failure(:extract_comments) do |e|
            expect(e.value!).to be_a ActiveRecord::ActiveRecordError
          end
        end
      end
    end
  end
end
