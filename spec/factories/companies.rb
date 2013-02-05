require 'faker'
FactoryGirl.define do
  factory :company do
    name { Faker::Company.name }
    slogan { Faker::Company.catch_phrase }
  end
end