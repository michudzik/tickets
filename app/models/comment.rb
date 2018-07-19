class Comment < ActiveRecord::Base
	
	validates :body, presence: true
	validates :body, length: { minimum: 5 }

	belongs_to :user
	belongs_to :ticket

	def comment_info
		"#{body} #{user_id} #{updated_at}"
	end
end