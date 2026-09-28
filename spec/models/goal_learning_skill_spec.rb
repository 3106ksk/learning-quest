require 'rails_helper'

RSpec.describe GoalLearningSkill, type: :model do
  describe "紐づけの作成" do
    context "目標と学習スキルの利用者が同じ場合" do
      it "保存できる" do
        goal_learning_skill = create(:goal_learning_skill)

        expect(goal_learning_skill).to be_persisted
        expect(goal_learning_skill.goal.user).to eq(goal_learning_skill.learning_skill.user)
      end
    end

    context "同じ目標と学習スキルの組み合わせが既にある場合" do
      it "2件目はバリデーションで保存できずエラーメッセージが表示される" do
        goal_learning_skill = create(:goal_learning_skill)
        duplicate = build(
          :goal_learning_skill,
          goal: goal_learning_skill.goal,
          learning_skill: goal_learning_skill.learning_skill
        )

        expect(duplicate).to be_invalid
        expect(duplicate.errors[:learning_skill_id]).to be_present
      end
    end
  end

  describe "紐づけの解除" do
    context "学習記録がある場合" do
      it "中間テーブルの行だけを削除し、学習スキル本体と学習記録は残す" do
        goal_learning_skill = create(:goal_learning_skill)
        learning_skill = goal_learning_skill.learning_skill
        study_record = create(
          :study_record,
          user: goal_learning_skill.goal.user,
          goal: goal_learning_skill.goal,
          learning_skill: learning_skill
        )

        expect { goal_learning_skill.destroy! }
          .to change(described_class, :count).by(-1)
          .and change(LearningSkill, :count).by(0)
          .and change(StudyRecord, :count).by(0)
        expect(study_record.reload.learning_skill).to eq(learning_skill)
      end
    end
  end
end
