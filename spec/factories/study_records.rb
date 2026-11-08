FactoryBot.define do
  factory :study_record do
    user
    goal { association(:goal, user: user) }
    planned_minutes { 25 }
    activity { "RSpecの学習" }
    started_at { Time.current }
    status { :running }
  end
end
