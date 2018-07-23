require 'rails_helper'

RSpec.describe Comment, type: :model do

	describe 'validations' do
		it { should validate_presence_of(:body) }
		it { should belong_to(:user) }
		it { should belong_to(:ticket) }		
	end

end