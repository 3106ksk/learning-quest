FactoryBot.define do
  factory :focus_option do
    sequence(:result_code) { |n| "focused_#{n}" }
    label { "集中できた" }
    point { 2 }
    sequence(:position)
  end
end
