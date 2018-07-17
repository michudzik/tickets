require 'rails_helper'

RSpec.describe Comment, type: :model do

	describe 'validations' do
		it { should validate_presence_of(:body) }
		it { should validate_length_of(:body).is_at_least(5) }
		# it { should belong_to(:ticket) }
		# it { should belong_to(:user) }
	end

end