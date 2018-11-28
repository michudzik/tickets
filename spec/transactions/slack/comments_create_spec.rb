require 'rails_helper'

RSpec.describe Slack::CommentsCreate do
  subject { described_class.new(current_user: user, params: ticket).call }
  let!(:user) { create(:user) }
  let!(:ticket) { create(:ticket) }
  let!(:comment) { create(:comment, ticket: ticket, user: user) }

  describe '#call' do
    context 'when transaction is successful' do
      it { expect(subject).to be_a Success }
    end

    describe '#extract_email' do
      it 'is a failure' do
        allow_any_instance_of(Ticket).to receive(:comments).and_raise ActiveRecord::ActiveRecordError
        expect(subject).to be_a Failure
      end
    end

    describe '#notify_users' do
      it 'is a failure' do
        allow_any_instance_of(SlackService).to receive(:call).and_raise ArgumentError
        expect(subject).to be_a Failure
      end
    end
  end
end
