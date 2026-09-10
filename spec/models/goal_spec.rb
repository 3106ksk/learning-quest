require 'rails_helper'

RSpec.describe Goal, type: :model do
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
