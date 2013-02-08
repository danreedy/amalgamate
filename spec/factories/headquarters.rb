require 'faker'
FactoryGirl.define do
  factory :headquarter do
    city { Faker::Address.city }
    company
  end
end