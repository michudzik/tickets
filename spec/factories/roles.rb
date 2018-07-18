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

  # factory :it_support, class: Role do
  #   name 'it_support'
  # end

  # factory :om_support, class: Role do
  #   name 'om_support'
  # end

  # factory :admin, class: Role do
  #   name 'admin'
  # end
end