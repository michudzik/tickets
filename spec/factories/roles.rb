FactoryBot.define do
  factory :role do

    trait :none do
      name 'none'
    end

    trait :it_support do
      name 'it_support'
    end

    trait :om_support do
      name 'om_support'
    end

    trait :admin do
      name 'admin'
    end
  end
end