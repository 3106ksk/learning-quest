require 'rails_helper'

RSpec.describe WeeklyReflection, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe ".current_week_start_on" do
    it "日本時間の日曜23:59には、その週の月曜日を返す" do
      travel_to Time.zone.local(2026, 11, 1, 23, 59, 0) do
        expect(described_class.current_week_start_on).to eq(Date.new(2026, 10, 26))
      end
    end

    it "日本時間の月曜0:00には、新しい週の月曜日を返す" do
      travel_to Time.zone.local(2026, 11, 2, 0, 0, 0) do
        expect(described_class.current_week_start_on).to eq(Date.new(2026, 11, 2))
      end
    end
  end

  describe "バリデーション" do
    context "作成時に目標へ使用設定していない学習スキルの場合" do
      it "無効になり、学習スキルIDにエラーが入る" do
        goal = create(:goal)
        learning_skill = create(:learning_skill, user: goal.user)
        weekly_reflection = build(:weekly_reflection, goal: goal, learning_skill: learning_skill)

        expect(weekly_reflection).to be_invalid
        expect(weekly_reflection.errors[:learning_skill_id]).to be_present
      end
    end

    context "作成後に学習スキルの使用設定を解除した場合" do
      it "実感と振り返った日時を更新できる" do
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
      it "無効になり、実感にエラーが入る" do
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

  describe "#skill_total" do
    let(:goal) { create(:goal) }
    let(:learning_skill) { create(:goal_skill_setting, goal: goal).learning_skill }
    let(:weekly_reflection) do
      create(:weekly_reflection, goal: goal, learning_skill: learning_skill, week_start_on: Date.new(2026, 10, 19))
    end

    context "この学習スキルの最初の週の場合" do
      it "週数1と、その週にこの学習スキルを選んだ回数を返す" do
        create_evaluated_record(started_at: Time.zone.local(2026, 10, 20, 9, 0, 0))
        create_evaluated_record(started_at: Time.zone.local(2026, 10, 21, 9, 0, 0))

        expect(weekly_reflection.skill_total).to eq({ weeks: 1, count: 2 })
      end
    end

    context "同じ学習スキルの週が2つある場合" do
      it "2週と、2週の回数の合計を返す" do
        create(:weekly_reflection, goal: goal, learning_skill: learning_skill, week_start_on: Date.new(2026, 10, 12))
        create_evaluated_record(started_at: Time.zone.local(2026, 10, 13, 9, 0, 0))
        create_evaluated_record(started_at: Time.zone.local(2026, 10, 20, 9, 0, 0))
        create_evaluated_record(started_at: Time.zone.local(2026, 10, 20, 21, 0, 0))

        expect(weekly_reflection.skill_total).to eq({ weeks: 2, count: 3 })
      end
    end

    context "ほかの学習スキルの週と、ほかの目標の週がある場合" do
      it "それらの週を数えない" do
        other_skill = create(:goal_skill_setting, goal: goal).learning_skill
        create(:weekly_reflection, goal: goal, learning_skill: other_skill, week_start_on: Date.new(2026, 10, 12))
        create_evaluated_record(started_at: Time.zone.local(2026, 10, 13, 9, 0, 0), learning_skill: other_skill)

        other_goal = create(:goal, :completed, user: goal.user)
        create(:goal_skill_setting, goal: other_goal, learning_skill: learning_skill)
        create(:weekly_reflection, goal: other_goal, learning_skill: learning_skill, week_start_on: Date.new(2026, 10, 12))
        create_evaluated_record(started_at: Time.zone.local(2026, 10, 13, 9, 0, 0), goal: other_goal)
        create_evaluated_record(started_at: Time.zone.local(2026, 10, 20, 9, 0, 0), goal: other_goal)

        create_evaluated_record(started_at: Time.zone.local(2026, 10, 20, 9, 0, 0))

        expect(weekly_reflection.skill_total).to eq({ weeks: 1, count: 1 })
      end
    end

    context "この週より先の週の行がある場合" do
      it "先の週を数えない" do
        create(:weekly_reflection, goal: goal, learning_skill: learning_skill, week_start_on: Date.new(2026, 10, 26))
        create_evaluated_record(started_at: Time.zone.local(2026, 10, 20, 9, 0, 0))
        create_evaluated_record(started_at: Time.zone.local(2026, 10, 27, 9, 0, 0))

        expect(weekly_reflection.skill_total).to eq({ weeks: 1, count: 1 })
      end
    end

    context "評価前・ほかの学習スキル・対象の週の外の学習がある場合" do
      it "数えない" do
        other_skill = create(:goal_skill_setting, goal: goal).learning_skill
        create_evaluated_record(started_at: Time.zone.local(2026, 10, 20, 9, 0, 0))
        create_evaluated_record(started_at: Time.zone.local(2026, 10, 22, 9, 0, 0), learning_skill: other_skill)
        create_evaluated_record(started_at: Time.zone.local(2026, 10, 18, 23, 59, 59))
        create_evaluated_record(started_at: Time.zone.local(2026, 10, 26, 0, 0, 0))
        create(
          :study_record,
          user: goal.user,
          goal: goal,
          learning_skill: learning_skill,
          started_at: Time.zone.local(2026, 10, 21, 9, 0, 0),
          status: :awaiting_evaluation
        )

        expect(weekly_reflection.skill_total).to eq({ weeks: 1, count: 1 })
      end
    end
  end

  private

  def create_evaluated_record(started_at:, goal: self.goal, learning_skill: self.learning_skill)
    create(
      :study_record,
      user: goal.user,
      goal: goal,
      learning_skill: learning_skill,
      started_at: started_at,
      status: :evaluated,
      rank: :a
    )
  end
end
