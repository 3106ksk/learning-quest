require 'rails_helper'

RSpec.describe GoalSkillSetting, type: :model do
  describe "紐づけの作成" do
    context "目標と学習スキルの利用者が同じ場合" do
      it "保存できる" do
        goal_skill_setting = create(:goal_skill_setting)

        expect(goal_skill_setting).to be_persisted
        expect(goal_skill_setting.goal.user).to eq(goal_skill_setting.learning_skill.user)
      end
    end

    context "同じ目標と学習スキルの組み合わせが既にある場合" do
      it "2件目はバリデーションで保存できずエラーメッセージが表示される" do
        goal_skill_setting = create(:goal_skill_setting)
        duplicate = build(
          :goal_skill_setting,
          goal: goal_skill_setting.goal,
          learning_skill: goal_skill_setting.learning_skill
        )

        expect(duplicate).to be_invalid
        expect(duplicate.errors[:learning_skill_id]).to be_present
      end
    end
  end

  describe "目標あたりの上限" do
    let(:goal) { create(:goal) }

    context "同じ目標に3件設定済みの場合" do
      it "4件目はバリデーションで保存できず、上限のエラーになる" do
        create_list(:goal_skill_setting, 3, goal: goal)
        fourth = build(:goal_skill_setting, goal: goal)

        expect(fourth).to be_invalid
        expect(fourth.errors.of_kind?(:base, :too_many_skills)).to be(true)
      end
    end

    context "同じ目標に2件設定済みの場合" do
      it "3件目は保存できる" do
        create_list(:goal_skill_setting, 2, goal: goal)

        expect(build(:goal_skill_setting, goal: goal)).to be_valid
      end
    end

    context "別の目標に3件設定済みの場合" do
      it "この目標には保存できる" do
        create_list(:goal_skill_setting, 3, goal: create(:goal))

        expect(build(:goal_skill_setting, goal: goal)).to be_valid
      end
    end
  end

  describe "紐づけの解除" do
    context "学習記録がある場合" do
      it "中間テーブルの行だけを削除し、学習スキル本体と学習記録は残す" do
        goal_skill_setting = create(:goal_skill_setting)
        learning_skill = goal_skill_setting.learning_skill
        study_record = create(
          :study_record,
          user: goal_skill_setting.goal.user,
          goal: goal_skill_setting.goal,
          learning_skill: learning_skill
        )

        expect { goal_skill_setting.destroy! }
          .to change(described_class, :count).by(-1)
          .and change(LearningSkill, :count).by(0)
          .and change(StudyRecord, :count).by(0)
        expect(study_record.reload.learning_skill).to eq(learning_skill)
      end
    end
  end
end
