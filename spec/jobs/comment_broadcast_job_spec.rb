require 'rails_helper'

RSpec.describe CommentBroadcastJob, type: :job do
  describe "#perform_later" do
    let(:comment) { build(:comment) }

    it "uploads a comment" do
      ActiveJob::Base.queue_adapter = :test
      expect{ comment.save }.to enqueue_job
    end
  end
end