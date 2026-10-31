require 'rails_helper'

RSpec.describe WeeklyStudyAggregator do
  include ActiveSupport::Testing::TimeHelpers

  let(:goal_created_at) { Time.zone.local(2026, 10, 1, 9, 0, 0) }
  let(:goal) { create(:goal, created_at: goal_created_at) }
  let(:learning_skill) { create(:goal_skill_setting, goal: goal).learning_skill }
  let(:week_start_on) { Date.new(2026, 10, 19) }
  let(:focus_options) { create_list(:focus_option, 3) }
  let(:challenge_options) { create_list(:challenge_option, 3) }

  subject(:result) do
    described_class.call(
      goal: goal,
      week_start_on: week_start_on,
      learning_skill: learning_skill
    )
  end

  describe "週の範囲" do
    it "日本時間の週の両端で、対象週と前週に振り分ける" do
      create_evaluated_record(started_at: Time.zone.local(2026, 10, 18, 23, 59, 59))
      create_evaluated_record(started_at: Time.zone.local(2026, 10, 19, 0, 0, 0))
      create_evaluated_record(started_at: Time.zone.local(2026, 10, 25, 23, 59, 59))
      create_evaluated_record(started_at: Time.zone.local(2026, 10, 26, 0, 0, 0))

      expect(result[:current][:study_count]).to eq(2)
      expect(result[:previous][:study_count]).to eq(1)
    end

    it "UTCでは日曜になる日本時間の月曜の朝に始めた学習を、対象週に数える" do
      create_evaluated_record(started_at: Time.zone.local(2026, 10, 19, 8, 59, 0))

      expect(result[:current][:study_count]).to eq(1)
      expect(result[:previous][:study_count]).to eq(0)
    end

    it "日曜に始めて翌週の月曜に終えた学習を、始めた週に数える" do
      create_evaluated_record(
        started_at: Time.zone.local(2026, 10, 25, 23, 30, 0),
        ended_at: Time.zone.local(2026, 10, 26, 0, 10, 0)
      )

      expect(result[:current][:study_count]).to eq(1)
    end
  end

  describe "数える学習" do
    it "評価済みでない学習は数えない" do
      create(
        :study_record,
        user: goal.user,
        goal: goal,
        status: :awaiting_evaluation,
        started_at: Time.zone.local(2026, 10, 20, 9, 0, 0)
      )

      expect(result[:current][:study_count]).to eq(0)
    end

    it "同じユーザーの別の目標と別のユーザーの学習は数えない" do
      other_goal = create(:goal, :completed, user: goal.user)
      other_user_goal = create(:goal)
      started_at = Time.zone.local(2026, 10, 20, 9, 0, 0)
      create_evaluated_record(goal: other_goal, started_at: started_at)
      create_evaluated_record(goal: other_user_goal, started_at: started_at)

      expect(result[:current][:study_count]).to eq(0)
    end
  end

  describe "学習した日数" do
    it "同じ日に2回学習すると、回数は2、日数は1になる" do
      create_evaluated_record(started_at: Time.zone.local(2026, 10, 20, 9, 0, 0))
      create_evaluated_record(started_at: Time.zone.local(2026, 10, 20, 21, 0, 0))

      expect(result[:current][:study_count]).to eq(2)
      expect(result[:current][:study_days]).to eq(1)
    end
  end

  describe "工夫を選んだ回" do
    let(:other_skill) { create(:goal_skill_setting, goal: goal).learning_skill }

    it "対象週の工夫を選んだ回だけを、対象週と前週のそれぞれで数える" do
      create_evaluated_record(started_at: Time.zone.local(2026, 10, 20, 9, 0, 0), learning_skill: learning_skill)
      create_evaluated_record(started_at: Time.zone.local(2026, 10, 21, 9, 0, 0), learning_skill: learning_skill)
      create_evaluated_record(started_at: Time.zone.local(2026, 10, 22, 9, 0, 0), learning_skill: other_skill)
      create_evaluated_record(started_at: Time.zone.local(2026, 10, 23, 9, 0, 0))
      create_evaluated_record(started_at: Time.zone.local(2026, 10, 13, 9, 0, 0), learning_skill: learning_skill)
      create_evaluated_record(started_at: Time.zone.local(2026, 10, 14, 9, 0, 0), learning_skill: other_skill)

      expect(result[:current][:selected_count]).to eq(2)
      expect(result[:previous][:selected_count]).to eq(1)
    end

    it "選ばれなかった選択肢も0回として、集中とチャレンジの内訳を表示順で返す" do
      [ [ 0, 0 ], [ 0, 1 ], [ 2, 1 ] ].each_with_index do |(focus_index, challenge_index), day|
        create_evaluated_record(
          started_at: Time.zone.local(2026, 10, 20 + day, 9, 0, 0),
          learning_skill: learning_skill,
          focus_option: focus_options[focus_index],
          challenge_option: challenge_options[challenge_index]
        )
      end

      expect(result[:current][:focus].keys).to eq(focus_options)
      expect(result[:current][:focus].values).to eq([ 2, 0, 1 ])
      expect(result[:current][:challenge].keys).to eq(challenge_options)
      expect(result[:current][:challenge].values).to eq([ 1, 2, 0 ])
    end
  end

  describe "前週に目標があったか" do
    context "目標が前週の日曜23:00に作られている場合" do
      let(:goal_created_at) { Time.zone.local(2026, 10, 18, 23, 0, 0) }

      it "前週の学習が0回でも、前週ありとして0回を返す" do
        expect(result[:previous_week_exists]).to be(true)
        expect(result[:previous][:study_count]).to eq(0)
      end
    end

    context "目標が対象週の月曜0:00に作られている場合" do
      let(:goal_created_at) { Time.zone.local(2026, 10, 19, 0, 0, 0) }

      it "前週なしになる" do
        expect(result[:previous_week_exists]).to be(false)
      end
    end
  end

  describe "対象週が終わったか" do
    it "対象週の日曜23:59:59には、終わっていない" do
      travel_to(Time.zone.local(2026, 10, 25, 23, 59, 59)) do
        expect(result[:week_finished]).to be(false)
      end
    end

    it "翌週の月曜0:00:00には、終わっている" do
      travel_to(Time.zone.local(2026, 10, 26, 0, 0, 0)) do
        expect(result[:week_finished]).to be(true)
      end
    end
  end

  def create_evaluated_record(
    started_at:,
    goal: self.goal,
    learning_skill: nil,
    ended_at: nil,
    focus_option: focus_options.first,
    challenge_option: challenge_options.first
  )
    create(
      :study_record,
      user: goal.user,
      goal: goal,
      learning_skill: learning_skill,
      started_at: started_at,
      ended_at: ended_at,
      status: :evaluated,
      rank: :a
    ).tap do |study_record|
      create(
        :evaluation,
        study_record: study_record,
        focus_option: focus_option,
        challenge_option: challenge_option
      )
    end
  end
end
