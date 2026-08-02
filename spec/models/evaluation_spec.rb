require 'rails_helper'

RSpec.describe Evaluation, type: :model do
  let(:user) { create(:user) }
  let(:study_record) do
    StudyRecord.create!(
      user: user,
      planned_minutes: 25,
      activity: "RSpecの学習",
      started_at: Time.current,
      status: :awaiting_evaluation
    )
  end
  let(:focus_option) do
    FocusOption.create!(
      result_code: "focused",
      label: "集中できた",
      point: 2,
      position: 1
    )
  end
  let(:challenge_option) do
    ChallengeOption.create!(
      result_code: "challenged",
      label: "挑戦できた",
      point: 3,
      position: 1
    )
  end

  describe "評価の保存" do
    it "選択肢のポイントをスナップショットとして保存する" do
      evaluation = described_class.create!(
        study_record: study_record,
        focus_option: focus_option,
        challenge_option: challenge_option
      )

      focus_option.update!(point: 1)
      challenge_option.update!(point: 1)

      expect(evaluation.reload.focus_point).to eq(2)
      expect(evaluation.challenge_point).to eq(3)
    end
  end

  describe "バリデーション" do
    it "集中とチャレンジが未選択の場合は無効である" do
      evaluation = described_class.new(study_record: study_record)

      expect(evaluation).not_to be_valid
      expect(evaluation.errors[:focus_option]).to be_present
      expect(evaluation.errors[:challenge_option]).to be_present
    end

    it "存在しない選択肢IDの場合は無効である" do
      evaluation = described_class.new(
        study_record: study_record,
        focus_option_id: -1,
        challenge_option_id: -1
      )

      expect(evaluation).not_to be_valid
      expect(evaluation.errors[:focus_option]).to be_present
      expect(evaluation.errors[:challenge_option]).to be_present
    end

    it "同じ学習記録に評価が存在する場合は無効である" do
      described_class.create!(
        study_record: study_record,
        focus_option: focus_option,
        challenge_option: challenge_option
      )

      duplicate_evaluation = described_class.new(
        study_record: study_record,
        focus_option: focus_option,
        challenge_option: challenge_option
      )

      expect(duplicate_evaluation).not_to be_valid
      expect(duplicate_evaluation.errors[:study_record_id]).to be_present
    end
  end
end
