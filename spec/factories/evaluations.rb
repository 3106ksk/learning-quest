FactoryBot.define do
  factory :evaluation do
    study_record do
      association(:study_record, status: :awaiting_evaluation)
    end
    focus_option
    challenge_option
  end
end
