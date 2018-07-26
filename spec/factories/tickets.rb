FactoryBot.define do
	factory :ticket do 
		title	{ Faker::Name.name }
		note	{ Faker::Lorem.sentences(3).join('') }
		user
		association :department
    association :status
    trait :om_department do
      association :department, :om
    end
	end
end