FactoryBot.define do
	factory :comment do |comment|
		comment.body	'comment'
		user
	end
end