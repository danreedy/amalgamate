require 'faker'
FactoryGirl.define do
  factory :company do
    name { Faker::Company.name }
    slogan { Faker::Company.catch_phrase }
    factory :company_with_headquarter do
      after(:create) do |company|
        FactoryGirl.create(:headquarter, company: company)
      end
    end
    factory :company_with_employees do
      ignore do
        employee_count 5
      end
      after(:create) do |company, employee|
        FactoryGirl.create_list(:employee, employee.employee_count, company: company)
      end
    end
  end
end