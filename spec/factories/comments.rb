FactoryBot.define do
	factory :comment do |comment|
		comment.body	'comment'
		association :create, factory: :user
	end
end