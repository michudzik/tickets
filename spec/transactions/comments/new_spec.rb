require 'rails_helper'

RSpec.describe Comments::New do
  describe '#call' do
    subject { described_class.new.call(ticket.id) }
    let(:ticket) { create(:ticket) }
    
    it 'is a success' do
      expect(subject).to be_a Success
    end

    it 'returns a comment' do
      subject do |r|
        r.success do |monad|
          expect(monad.value!).to be_a Comment
        end
      end
    end

    it 'does not create new comment' do
      expect{ subject }.not_to change{ Comment.count }
    end
  end
end
