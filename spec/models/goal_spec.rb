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

  describe "#destroy!" do
    context "学習記録と評価がある場合" do
      it "紐づく学習記録と評価も削除される" do
        user = create(:user)
        goal = create(:goal, user: user)
        study_record = create(
          :study_record,
          user: user,
          goal: goal,
          status: :awaiting_evaluation
        )
        create(:evaluation, study_record: study_record)

        expect { goal.destroy! }
          .to change(Goal, :count).by(-1)
          .and change(StudyRecord, :count).by(-1)
          .and change(Evaluation, :count).by(-1)
      end
    end

    context "学習スキルとの紐づけがある場合" do
      it "目標と中間テーブルの行を削除し、学習スキル本体は残す" do
        goal_skill_setting = create(:goal_skill_setting)
        goal = goal_skill_setting.goal
        learning_skill = goal_skill_setting.learning_skill

        expect { goal.destroy! }
          .to change(Goal, :count).by(-1)
          .and change(GoalSkillSetting, :count).by(-1)
          .and change(LearningSkill, :count).by(0)
        expect(learning_skill.reload).to be_persisted
      end
    end
  end

  describe "#learning_skills" do
    context "選択済みと未選択の学習スキルがある場合" do
      it "学習開始フォームの候補となる選択済みスキルだけを返す" do
        goal = create(:goal)
        selected_skill = create(:learning_skill, user: goal.user)
        create(:learning_skill, user: goal.user)
        create(:goal_skill_setting, goal: goal, learning_skill: selected_skill)

        expect(goal.learning_skills).to contain_exactly(selected_skill)
      end
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
