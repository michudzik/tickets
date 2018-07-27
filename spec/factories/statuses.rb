FactoryBot.define do
  factory :status do
    name 'open'
    
    trait :user_response do
      name 'user_response'
    end

    trait :support_response do
      name 'support_response'
    end

    trait :closed do
      name 'closed' 
    end
  end
end