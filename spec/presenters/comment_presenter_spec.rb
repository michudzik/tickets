require 'rails_helper'

RSpec.describe CommentPresenter, type: :presenter do
  let(:user) { create(:user, role: role, first_name: 'First', last_name: 'Last') }
  let(:role) { create(:role, :it_support) }
  let(:comment) { create(:comment, user: user, body: "Twoline\nBody") }

  describe '#methods' do
    subject { described_class.new(comment) }

    describe '#created_at' do
      it 'returns properly formatted date' do
        expect(subject.created_at).to eq comment.created_at.strftime("%H:%M")
      end
    end

    describe '#created_at_tooltip' do
      it 'returns properly formatted date' do
        expect(subject.created_at_tooltip).to eq comment.created_at.strftime("%A, %Y.%m.%d, %H:%M")
      end
    end

    describe '#body' do
      it 'returns properly formatted body' do
        expect(subject.body).to eq 'Twoline<br />Body'
      end
    end

    describe '#shortened_comment' do
      let(:comment) { create(:comment, user: user, body: 'a'*41) }

      it 'returns shortened comment body with a created at date' do
        expect(subject.shortened_comment).to eq "(#{subject.created_at}): #{'a'*25}... (continued)"
      end
    end

    describe '#author' do
      it 'returns properly formatted string' do
        expect(subject.author).to eq "First Last (It support)"
      end
    end
  end
end
