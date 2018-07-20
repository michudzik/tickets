FactoryBot.define do
  factory :status do
    trait :open do
      status 'open'
    end

    trait :user_response do
      status 'user_response'
    end

    trait :support_response do
      status 'support_response'
    end

    trait :closed do
      status 'closed' 
    end
  end
end