require 'rails_helper'

RSpec.describe CommentsController, type: :controller do

	describe '#create' do

		let(:user) { create(:user) }
		let(:ticket) { create(:ticket) }
		let(:valid_attributes) { { user_id: user.id, ticket_id: ticket.id, comment: attributes_for(:comment) } }
		
		it 'should create comment' do
			sign_in user
			expect { post :create, params: valid_attributes }.to change(Comment,:count).by(1)
			expect(response).to redirect_to user_dashboard_url
		end
	end

	# describe '#create' do
	# 	let(:comment) { create(:comment) }
	# 	let(:valid_attributes) { { comment: attributes_for(:comment) } }
	# end

end