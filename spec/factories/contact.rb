require 'faker'
FactoryBot.define do
  factory :contact do
    full_name { Faker::Name.name }
    email { Faker::Internet.email }
    phone { "+55#{Faker::Number.number(digits: 2)}#{Faker::Number.number(digits: 9)}" }
  end
end
