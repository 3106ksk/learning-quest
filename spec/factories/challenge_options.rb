FactoryBot.define do
  factory :challenge_option do
    sequence(:result_code) { |n| "challenged_#{n}" }
    label { "挑戦できた" }
    point { 3 }
    sequence(:position)
  end
end
