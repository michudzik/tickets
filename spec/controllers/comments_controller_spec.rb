require 'rails_helper'

RSpec.describe CommentsController, type: :controller do

	describe '#create' do

		let(:ticket) { create(:ticket) }
		# { user.ticket.create(valid_attributes) }
		let(:valid_attributes) { { comment: { user_id: ticket.user.id, ticket_id: ticket.id, body: 'a'*20 } } }
		subject { post :create, params: valid_attributes }
		let(:status) { create(:status, :closed) }

		it 'should create comment' do
			puts ticket.errors.full_messages
			sign_in ticket.user
			expect{subject}.to change{Comment.count}.by(1)
		end

		it 'should not create comment when ticket is closed' do
			ticket.status = status
			ticket.save

			sign_in ticket.user
			expect{subject}.not_to change{Comment.count}
		end


	end

	# describe '#create' do
	# 	let(:comment) { create(:comment) }
	# 	let(:valid_attributes) { { comment: attributes_for(:comment) } }
	# end

end