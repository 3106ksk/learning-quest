FactoryBot.define do
  factory :goal_skill_setting do
    goal
    learning_skill { association(:learning_skill, user: goal.user) }
  end
end
