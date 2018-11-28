require 'rails_helper'

RSpec.describe Slack::TicketsCreate do
  subject { described_class.new(current_user: user, params: ticket).call }
  let(:user) { create(:user) }
  let(:ticket) { create(:ticket, :om_department, user: user) }
  let!(:om_support) { create(:user, :om_support) }

  describe '#call' do
    context 'when transaction is successful' do
      before { allow_any_instance_of(SlackService).to receive(:call) }
      it { expect(subject).to be_a Success }
    end

    describe '#pick_emails' do
      it 'is a failure' do
        allow_any_instance_of(SlackService).to receive(:call)
        allow(User).to receive(:joins).and_raise ActiveRecord::ActiveRecordError
        expect(subject).to be_a Failure
     end
    end

    describe '#send_notifications' do
      it 'is a failure' do
        allow_any_instance_of(SlackService).to receive(:call).and_raise ArgumentError
        expect(subject).to be_a Failure
      end
    end
  end
end
