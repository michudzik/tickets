FactoryBot.define do
  factory :department do
    department_name 'IT'
    trait :om do
      department_name 'OM'
    end

  end
end