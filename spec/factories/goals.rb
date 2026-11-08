FactoryBot.define do
  factory :goal do
    user
    sequence(:name) { |n| "目標#{n}" }
    status { "active" }
    completed_at { nil }

    trait :completed do
      status { "completed" }
      completed_at { Time.current }
    end
  end
end
