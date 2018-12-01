require 'rails_helper'

RSpec.describe Tickets::New do
  subject { described_class.new.call(user) }
  let(:user) { create(:user) }
  
  describe '#call' do
    it 'is a success' do
      expect(subject).to be_a Success
    end
    
    it 'returns ticket object' do
      subject do |r|
        r.success do |monad|
          expect(monad.value!).to be_a Ticket
          expect(monad.value!.persisted?).to eq false
        end
      end
    end

    it 'does not create new ticket' do
      expect{ subject }.not_to change{ Ticket.count }
    end
  end
end
