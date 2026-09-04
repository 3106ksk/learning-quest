FactoryBot.define do
  factory :user do
    account_name { "テストユーザー" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "Password123!" }
    password_confirmation { "Password123!" }
  end
end
