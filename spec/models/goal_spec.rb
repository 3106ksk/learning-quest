require 'rails_helper'

RSpec.describe Goal, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe "#complete!" do
    it "進行中の目標を完了にし、完了日時を保存する" do
      goal = create(:goal)
      completed_at = Time.zone.local(2026, 9, 20, 12, 0, 0)

      travel_to(completed_at) { goal.complete! }

      expect(goal.reload).to be_completed
      expect(goal.completed_at).to eq(completed_at)
    end

    it "完了済みの目標は再度完了できず、状態と完了日時を変えない" do
      completed_at = Time.zone.local(2026, 9, 19, 12, 0, 0)
      goal = create(:goal, :completed, completed_at: completed_at)

      expect { goal.complete! }.to raise_error(RuntimeError)

      expect(goal.reload.status).to eq("completed")
      expect(goal.completed_at).to eq(completed_at)
    end
  end

  describe "学習記録との関連付け" do
    it "削除すると紐づく学習記録も削除される" do
      user = create(:user)
      goal = create(:goal, user: user)
      StudyRecord.create!(
        user: user,
        goal: goal,
        planned_minutes: 25,
        activity: "RSpecの学習",
        started_at: Time.current,
        status: :running
      )

      expect { goal.destroy! }.to change(StudyRecord, :count).by(-1)
    end
  end

  describe "バリデーション" do
    it "目標名が空だと保存できない" do
      goal = build(:goal, name: "")

      expect(goal).to be_invalid
      expect(goal.errors[:name]).to be_present
    end

    it "目標名が100文字なら保存できる" do
      goal = build(:goal, name: "あ" * 100)

      expect(goal).to be_valid
    end

    it "目標名が101文字だと保存できない" do
      goal = build(:goal, name: "あ" * 101)

      expect(goal).to be_invalid
      expect(goal.errors[:name]).to be_present
    end

    it "進行中の目標があるユーザーは新しい目標を作成できない" do
      user = create(:user)
      create(:goal, user: user)

      goal = build(:goal, user: user)

      expect(goal).to be_invalid
      expect(goal.errors[:user_id]).to be_present
    end

    it "完了済みの目標があるユーザーは新しい目標を作成できる" do
      user = create(:user)
      create(:goal, :completed, user: user)

      new_goal = build(:goal, user: user)

      expect(new_goal).to be_valid
    end
  end
end
