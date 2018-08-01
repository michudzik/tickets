FactoryBot.define do
	factory :comment do 
		body  { Faker::Lorem.sentences(3).join('') }
		user
    ticket
	end
end