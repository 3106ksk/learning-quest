FactoryBot.define do
  factory :weekly_reflection do
    goal
    learning_skill { create(:goal_skill_setting, goal: goal).learning_skill }
    week_start_on { Date.current.beginning_of_week }
    expectation { "focus" }
    expectation_note { nil }
    feeling { nil }
    comment { nil }
    reflected_at { nil }
  end
end
