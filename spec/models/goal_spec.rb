require 'rails_helper'

RSpec.describe Goal, type: :model do
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

  describe "#complete!" do
    it "完了すると完了済みになり完了日時が記録される" do
      goal = create(:goal)

      expect {
        goal.complete!
      }.to change { goal.reload.completed_at }.from(nil)

      expect(goal.reload).to be_completed
    end
  end
end
