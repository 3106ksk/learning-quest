FactoryBot.define do
  factory :goal_learning_skill do
    goal
    learning_skill { association(:learning_skill, user: goal.user) }
  end
end
