class Comment < ActiveRecord::Base
	
	validates :body, presence: true
	validates :body, length: { minimum: 5 }

	def comment_info
		"#{body} #{user_id}"
	end
end