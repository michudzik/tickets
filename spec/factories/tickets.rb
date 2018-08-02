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

    trait :user_response do
      association :status, :user_response
    end

    trait :support_response do
      association :status, :support_response
    end

    trait :closed do
      association :status, :closed
    end

	end
end