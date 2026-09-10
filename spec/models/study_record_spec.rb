require 'rails_helper'

RSpec.describe StudyRecord, type: :model do
  describe "目標との関連付け" do
    let(:user) { create(:user) }
    let(:goal) { create(:goal, user: user) }
    let(:attributes) do
      {
        user: user,
        planned_minutes: 25,
        activity: "RSpecの学習",
        started_at: Time.current,
        status: :running
      }
    end

    it "目標に紐づいて保存できる" do
      study_record = described_class.create!(attributes.merge(goal: goal))

      expect(study_record.reload.goal_id).to eq(goal.id)
    end

    it "目標がセットされていない場合は保存できない" do
      study_record = described_class.new(attributes)

      expect(study_record).to be_invalid
      expect(study_record.errors[:goal]).to be_present
    end
  end

  describe "#mark_as_evaluated!" do
    it "評価待ち以外の学習記録は評価済みに変更できない" do
      user = create(:user)
      study_record = described_class.create!(
        user: user,
        goal: create(:goal, user: user),
        planned_minutes: 25,
        activity: "RSpecの学習",
        started_at: Time.current,
        status: :running
      )

      expect {
        study_record.mark_as_evaluated!(:a)
      }.to raise_error(RuntimeError, "評価待ちの記録だけ評価完了にできます")

      expect(study_record.reload).to be_running
    end
  end
end
