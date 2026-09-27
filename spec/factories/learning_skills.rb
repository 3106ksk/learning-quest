FactoryBot.define do
  factory :learning_skill do
    user
    sequence(:name) { |n| "学習スキル#{n}" }
  end
end
