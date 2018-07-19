FactoryBot.define do
  factory :department do

    trait :it do
      department_name 'IT'
    end

    trait :om do
      department_name 'OM'
    end

  end
end