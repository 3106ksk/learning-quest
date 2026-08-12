FactoryBot.define do
  factory :user do
    name { "テストユーザー" }
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "Password123!" }
    password_confirmation { "Password123!" }
  end
end
