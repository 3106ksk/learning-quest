require "rails_helper"

RSpec.describe "Weekly reflections", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:goal) { create(:goal, user: user) }
  let(:learning_skill) { create(:goal_skill_setting, goal: goal).learning_skill }
  let(:valid_params) do
    {
      learning_skill_id: learning_skill.id,
      expectation: "focus",
      expectation_note: "学習中に次に何をするかで迷いにくくしたい"
    }
  end

  before do
    sign_in(user)
  end

  describe "POST /goals/:goal_id/weekly_reflections" do
    context "フォームの３項目を送信した時" do
      it "1件保存され、その週の画面へ303で移る" do
        travel_to Time.zone.local(2026, 11, 4, 12, 0, 0) do
          expect {
            post goal_weekly_reflections_path(goal), params: { weekly_reflection: valid_params }
          }.to change(WeeklyReflection, :count).by(1)

          weekly_reflection = goal.weekly_reflections.sole
          expect(weekly_reflection.learning_skill_id).to eq(learning_skill.id)
          expect(weekly_reflection.expectation).to eq("focus")
          expect(weekly_reflection.expectation_note).to eq(valid_params[:expectation_note])
          expect(response).to have_http_status(:see_other)
          expect(response).to redirect_to(goal_weekly_reflection_path(goal, weekly_reflection))
          expect(weekly_reflection.week_start_on).to eq(Date.new(2026, 11, 2))
        end
      end
    end

    context "週・実感・振り返りを保存した日時も一緒に送る場合" do
      it "送った週は使われず、実感と日時は空のまま保存される" do
        submitted_params = valid_params.merge(
          week_start_on: "2020-01-06",
          feeling: "felt",
          reflected_at: "2020-01-12T12:00:00+09:00"
        )

        expect {
          post goal_weekly_reflections_path(goal), params: { weekly_reflection: submitted_params }
        }.to change(WeeklyReflection, :count).by(1)

        weekly_reflection = goal.weekly_reflections.sole
        expect(weekly_reflection.week_start_on).not_to eq(Date.new(2020, 1, 6))
        expect(weekly_reflection.feeling).to be_nil
        expect(weekly_reflection.reflected_at).to be_nil
      end
    end

    context "他人の目標の場合" do
      it "保存せず404を返す" do
        other_goal = create(:goal)

        expect {
          post goal_weekly_reflections_path(other_goal), params: { weekly_reflection: valid_params }
        }.not_to change(WeeklyReflection, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "完了した目標の場合" do
      let(:goal) { create(:goal, :completed, user: user) }

      it "保存せず、目標詳細へ303で戻して完了済みの文言を表示する" do
        expect {
          post goal_weekly_reflections_path(goal), params: { weekly_reflection: valid_params }
        }.not_to change(WeeklyReflection, :count)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_path(goal))
        expect(flash[:danger]).to eq("この目標は既に完了しています")
      end
    end

    context "保存時にDBの一意制約に当たった場合" do
      it "行は1件のまま、既存の今週の画面へ303で移る" do
        weekly_reflection = create(:weekly_reflection, goal: goal, learning_skill: learning_skill)
        allow_any_instance_of(WeeklyReflection).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)

        expect {
          post goal_weekly_reflections_path(goal), params: { weekly_reflection: valid_params }
        }.not_to change(WeeklyReflection, :count)

        expect(goal.weekly_reflections.count).to eq(1)
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_weekly_reflection_path(goal, weekly_reflection))
      end
    end
  end
end
