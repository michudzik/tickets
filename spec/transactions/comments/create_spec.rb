require 'rails_helper'
require 'net/smtp'

RSpec.describe Comments::Create do
  subject { described_class.new(current_user: user, params: params).call }
  let(:user) { create(:user) }
  let(:ticket) { create(:ticket, user: user) }
  let(:ticket_id) { ticket.id }
  let(:params) { { ticket_id: ticket_id, user_id: user.id, body: 'a'*50 } }

  describe '#call' do
    context 'when transaction is successful' do
      it 'is successful' do
        expect(subject).to be_a Success
      end

      it 'returns a ticket' do
        subject do |r|
          r.success do |monad|
            expect(monad.value!).to eq ticket
          end
        end
      end

      it 'creates a comment' do
        expect{ subject }.to change{ Comment.count }.by 1
      end

      it 'changes ticket status' do
        create(:status, :user_response)
        create(:status, :support_response)
        expect{ subject }.to change{ ticket.reload.status }
      end

      it 'calls user notifier service' do
        expect_any_instance_of(UserNotifierService).to receive(:call)
        subject
      end
    end

    describe '#assign_ticket' do
      let(:ticket_id) { -5 }

      it { expect(subject).to be_a Failure }

      it 'returns wrapped error' do
        subject do |r|
          r.failure(:assign_ticket) do |e|
            expect(e.value!).to be_a ActiveRecord::RecordNotFound
          end
        end
      end
    end

    describe '#closed' do
      let(:ticket) { create(:ticket, :closed, user: user) }

      it { expect(subject).to be_a Failure }

      it 'returns a ticket' do
        subject do |r|
          r.failure(:closed) do |e|
            expect(e.value!).to eq ticket
          end
        end
      end
    end

    describe '#validate' do
      let(:params) { { ticket_id: ticket_id, user_id: user.id, body: nil } }

      it { expect(subject).to be_a Failure }

      it 'returns schema with errors' do
        subject do |r|
          r.failure(:validate) do |e|
            expect(e.value!.errors).to have_key(:body)
            expect(e.value.errors[:body]).to eq 'must be filled'
          end
        end
      end
    end

    describe '#create_comment' do
      it 'is a failure' do
        allow(Comment).to receive(:create).and_raise(ActiveRecord::ActiveRecordError)
        expect(subject).to be_a Failure
      end

      it 'returns a wrapped exception' do
        allow(Comment).to receive(:create).and_raise(ActiveRecord::ActiveRecordError)
        subject do |r|
          r.failure(:create_comment) do |e|
            expect(e.value!).to be_a ActiveRecord::ActiveRecordError
          end
        end
      end
    end

    describe '#notify_users_via_email' do
      it 'is a failure' do
        allow_any_instance_of(UserNotifierService).to receive(:call).and_raise Net::SMTPServerBusy
        expect(subject).to be_a Failure
      end

      it 'returns wrapped exception' do
        allow_any_instance_of(UserNotifierService).to receive(:call).and_raise Net::SMTPServerBusy
        subject do |r|
          r.failure(:notify_users_via_email) do |e|
            expect(e.value!).to be_a Net::SMTPServerBusy
          end
        end
      end
    end

    describe '#notify_users_via_slack' do
      it 'is a failure' do
        allow_any_instance_of(Slack::CommentsCreate).to receive(:extract_email).and_raise ActiveRecord::ActiveRecordError
        expect(subject).to be_a Failure
      end

      it 'returns wrapped ticket' do
        allow_any_instance_of(Slack::CommentsCreate).to receive(:extract_email).and_raise ActiveRecord::ActiveRecordError
        subject do |r|
          r.failure(:notify_users_via_slack) do |e|
            expect(e.value!).to be_a Ticket
          end
        end
      end
    end
  end
end
