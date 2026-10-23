require 'rails_helper'

RSpec.describe WeeklyReflection, type: :model do
  describe "バリデーション" do
    context "作成時に目標へ使用設定していない学習スキルの場合" do
      it "無効になり、学習スキルIDにエラーが入る", skip: "使用設定の検証は保存機能の実装時に追加する" do
        goal = create(:goal)
        learning_skill = create(:learning_skill, user: goal.user)
        weekly_reflection = build(:weekly_reflection, goal: goal, learning_skill: learning_skill)

        expect(weekly_reflection).to be_invalid
        expect(weekly_reflection.errors[:learning_skill_id]).to be_present
      end
    end

    context "作成後に学習スキルの使用設定を解除した場合" do
      it "実感と振り返った日時を更新できる", skip: "作成時だけ使用設定を検証することは保存・更新機能の実装時に確認する" do
        weekly_reflection = create(:weekly_reflection)
        setting = GoalSkillSetting.find_by!(
          goal: weekly_reflection.goal,
          learning_skill: weekly_reflection.learning_skill
        )
        setting.destroy!
        reflected_at = Time.current.change(usec: 0)

        expect(weekly_reflection.update(feeling: "felt", reflected_at: reflected_at)).to be(true)
        expect(weekly_reflection.reload.feeling).to eq("felt")
        expect(weekly_reflection.reflected_at).to eq(reflected_at)
      end
    end

    context "振り返った日時があって実感が空の場合" do
      it "無効になり、実感にエラーが入る", skip: "実感と振り返った日時の検証は保存・更新機能の実装時に追加する" do
        weekly_reflection = build(:weekly_reflection, feeling: nil, reflected_at: Time.current)

        expect(weekly_reflection).to be_invalid
        expect(weekly_reflection.errors[:feeling]).to be_present
      end
    end

    context "同じ目標・同じ週の振り返りが既にある場合" do
      it "2件目は無効になり、週にエラーが入る" do
        weekly_reflection = create(:weekly_reflection)
        duplicate = build(
          :weekly_reflection,
          goal: weekly_reflection.goal,
          learning_skill: weekly_reflection.learning_skill,
          week_start_on: weekly_reflection.week_start_on
        )

        expect(duplicate).to be_invalid
        expect(duplicate.errors[:week_start_on]).to be_present
      end
    end
  end

  describe "関連データの削除" do
    context "目標を削除した場合" do
      it "紐づく週の振り返りも削除される" do
        weekly_reflection = create(:weekly_reflection)

        expect { weekly_reflection.goal.destroy! }
          .to change(described_class, :count).by(-1)
      end
    end
  end
end
