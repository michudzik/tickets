FactoryBot.define do
  factory :user do
    first_name    { Faker::Name.first_name }
    last_name     { Faker::Name.last_name }
    email         { "#{Faker::Name.first_name}@#{Faker::Name.last_name}.com" }
    password      'secret'
    confirmed_at  { DateTime.now }
    association :role

    trait :admin do
      association :role, :admin
    end

    trait :it_support do
      association :role, :it_support
    end

    trait :om_support do
      association :role, :om_support
    end
  end
end