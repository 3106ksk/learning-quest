require 'rails_helper'

RSpec.describe "StudyRecords", type: :request do
  let(:user) { create(:user) }
  let(:goal) { create(:goal, user: user) }
  let(:study_record) do
    StudyRecord.create!(
      user: user,
      goal: goal,
      planned_minutes: 25,
        activity: "RSpecの学習",
        started_at: Time.current,
        status: study_record_status,
        rank: study_record_status == :evaluated ? :a : nil,
        current_pause_started_at: study_record_status == :paused ? Time.current : nil
    )
  end

  before do
    sign_in(user)
  end

  describe "POST /study_records" do
    it "完了済み目標ではなく現在の目標を新しい学習記録へ保存する" do
      create(:goal, :completed, user: user)
      current_goal = create(:goal, user: user)
      create(:goal, :completed, user: user)

      post study_records_path, params: {
        study_record: {
          planned_minutes: 25,
          activity: "RSpecの学習"
        }
      }

      study_record = user.study_records.order(:created_at).last

      expect(study_record.goal_id).to eq(current_goal.id)
    end

    it "目標がないときは学習記録を作らず入力を保持して422を返す" do
      expect {
        post study_records_path, params: {
          study_record: { planned_minutes: 25, activity: "RSpecの学習" }
        }
      }.not_to change(StudyRecord, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("RSpecの学習", "まずは目標を設定してください。")
    end

    %w[paused awaiting_evaluation].each do |status|
      it "不正なstatus(#{status})を送っても、学習記録はrunningで保存される" do
        goal

        post study_records_path, params: {
          study_record: { planned_minutes: 25, activity: "RSpecの学習", status: status }
        }

        expect(response).to have_http_status(:see_other)
        expect(user.study_records.order(:created_at).last.status).to eq("running")
      end
    end

    context "保存に失敗して422で再表示する場合" do
      it "今の目標に設定した学習スキルを表示する" do
        create(:goal_skill_setting, goal: goal, learning_skill: create(:learning_skill, user: user, name: "今の目標のスキル"))

        post study_records_path, params: { study_record: { planned_minutes: 25, activity: "" } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("今の目標のスキル")
      end
    end
  end

  describe "GET /study_records/:id" do
    [ :running, :paused ].each do |status|
      context "学習記録が#{status}の場合" do
        let(:study_record_status) { status }

        it "学習画面を表示する" do
          get study_record_path(study_record)

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "学習記録が評価待ちの場合" do
      let(:study_record_status) { :awaiting_evaluation }

      it "評価入力画面へ遷移する" do
        get study_record_path(study_record)

        expect(response).to redirect_to(new_study_record_evaluation_path(study_record))
        expect(response).to have_http_status(:see_other)
      end
    end

    context "学習記録が評価済みの場合" do
      let(:study_record_status) { :evaluated }

      it "評価結果画面へ遷移する" do
        get study_record_path(study_record)

        expect(response).to redirect_to(study_record_evaluation_path(study_record))
        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe "GET /study_records/new" do
    it "評価済みの学習記録があっても新規学習フォームを表示する" do
      StudyRecord.create!(
        user: user,
        goal: goal,
        planned_minutes: 25,
        activity: "完了した学習",
        started_at: Time.current,
        status: :evaluated,
        rank: :a
      )

      get new_study_record_path

      expect(response).to have_http_status(:ok)
    end

    describe "学習スキルの選択フィールド" do
      def create_setting(goal:, name:)
        create(:goal_skill_setting, goal: goal, learning_skill: create(:learning_skill, user: goal.user, name: name))
      end

      it "進行中の目標に設定した学習スキルだけを表示" do
        create_setting(goal: goal, name: "今の目標のスキル")
        create_setting(goal: create(:goal, :completed, user: user), name: "完了した目標のスキル")
        create_setting(goal: create(:goal), name: "他ユーザーのスキル")

        get new_study_record_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("今の目標のスキル")
        expect(response.body).not_to include("完了した目標のスキル", "他ユーザーのスキル")
      end

      it "目標があり学習スキルが0件のとき、スキル設定画面へのリンクを表示し、選択を外す欄は出さない" do
        goal

        get new_study_record_path

        expect(response.body).to include("この目標で使う学習スキルを選べます", goal_skill_settings_path(goal))
        assert_select "input[name='study_record[learning_skill_id]']", count: 0
      end

      it "進行中の目標がないとき、学習スキルの名前も設定画面へのリンクも表示しない" do
        create_setting(goal: create(:goal, :completed, user: user), name: "完了した目標のスキル")

        get new_study_record_path

        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("完了した目標のスキル", "この目標で使う学習スキルを選べます")
        assert_select "input[name='study_record[learning_skill_id]']", count: 0
      end

      it "前回学習で使用したスキルは未選択で表示する" do
        skill = create_setting(goal: goal, name: "前回使ったスキル").learning_skill
        create(:study_record, user: user, goal: goal, learning_skill: skill, status: :evaluated, rank: :a)

        get new_study_record_path

        assert_select "input[name='study_record[learning_skill_id]'][value='#{skill.id}']", count: 1
        assert_select "input[name='study_record[learning_skill_id]'][value='#{skill.id}'][checked]", count: 0
        assert_select "input[name='study_record[learning_skill_id]'][value=''][checked]", count: 1
      end
    end
  end
end
