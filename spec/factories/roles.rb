FactoryBot.define do
  factory :none, class: Role do
    name 'none'
  end

  factory :it_support, class: Role do
    name 'it_support'
  end

  factory :om_support, class: Role do
    name 'om_support'
  end

  factory :admin, class: Role do
    name 'admin'
  end
end