FactoryBot.define do
  factory :user do
    first_name    { Faker::Name.first_name }
    last_name     { Faker::Name.last_name }
    email         { "#{Faker::Name.first_name}@example.com" }
    password      'secret'
    confirmed_at  { DateTime.now }
    association :role, factory: :none
  end

  factory :admin_user, class: User do
    first_name    { Faker::Name.first_name }
    last_name     { Faker::Name.last_name }
    email         { "#{Faker::Name.first_name}@example.com" }
    password      'secret'
    confirmed_at  { DateTime.now }
    association :role, factory: :admin
  end
end