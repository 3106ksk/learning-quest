require "rails_helper"

RSpec.describe "Reviews", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:goal) { create(:goal, user: user) }
  let(:learning_skill) { create(:goal_skill_setting, goal: goal).learning_skill }
  let(:weekly_reflection) do
    create(:weekly_reflection, goal: goal, learning_skill: learning_skill, week_start_on: Date.new(2026, 11, 2))
  end
  let(:valid_params) { { feeling: "felt", comment: "迷いにくくなった気がする" } }

  before do
    sign_in(user)
  end

  describe "PATCH /goals/:goal_id/weekly_reflections/:weekly_reflection_id/review" do
    context "進行中の目標で実感とひと言を送った場合" do
      it "実感・ひと言・振り返った日時を保存し、その週の結果の画面へ303で移る" do
        travel_to Time.zone.local(2026, 11, 4, 12, 0, 0) do
          patch goal_weekly_reflection_review_path(goal, weekly_reflection), params: { weekly_reflection: valid_params }

          weekly_reflection.reload
          expect(weekly_reflection.feeling).to eq("felt")
          expect(weekly_reflection.comment).to eq("迷いにくくなった気がする")
          expect(weekly_reflection.reflected_at).to eq(Time.zone.local(2026, 11, 4, 12, 0, 0))
          expect(response).to have_http_status(:see_other)
          expect(response).to redirect_to(goal_weekly_reflection_review_path(goal, weekly_reflection))
        end
      end
    end

    context "保存済みの週を直した場合" do
      it "行は増えず、値と振り返った日時が新しくなり、ほかの週は変わらない" do
        previous_week = create(
          :weekly_reflection,
          goal: goal,
          learning_skill: learning_skill,
          week_start_on: Date.new(2026, 10, 26),
          feeling: "unsure",
          comment: "前の週",
          reflected_at: Time.zone.local(2026, 10, 28, 12, 0, 0)
        )
        weekly_reflection.update!(
          feeling: "felt",
          comment: "一回目",
          reflected_at: Time.zone.local(2026, 11, 4, 12, 0, 0)
        )

        travel_to Time.zone.local(2026, 11, 6, 21, 0, 0) do
          expect {
            patch goal_weekly_reflection_review_path(goal, weekly_reflection), params: {
              weekly_reflection: { feeling: "not_much", comment: "直した" }
            }
          }.not_to change(WeeklyReflection, :count)

          weekly_reflection.reload
          expect(weekly_reflection.feeling).to eq("not_much")
          expect(weekly_reflection.comment).to eq("直した")
          expect(weekly_reflection.reflected_at).to eq(Time.zone.local(2026, 11, 6, 21, 0, 0))

          previous_week.reload
          expect(previous_week.feeling).to eq("unsure")
          expect(previous_week.comment).to eq("前の週")
          expect(previous_week.reflected_at).to eq(Time.zone.local(2026, 10, 28, 12, 0, 0))
        end
      end
    end

    context "学習スキル・期待する変化・週・振り返った日時も一緒に送った場合" do
      it "実感とひと言だけが変わり、送ったほかの値は使われない" do
        other_skill = create(:goal_skill_setting, goal: goal).learning_skill
        submitted_params = valid_params.merge(
          learning_skill_id: other_skill.id,
          expectation: "challenge",
          week_start_on: "2020-01-06",
          reflected_at: "2020-01-12T12:00:00+09:00"
        )

        travel_to Time.zone.local(2026, 11, 4, 12, 0, 0) do
          patch goal_weekly_reflection_review_path(goal, weekly_reflection), params: { weekly_reflection: submitted_params }

          weekly_reflection.reload
          expect(weekly_reflection.feeling).to eq("felt")
          expect(weekly_reflection.learning_skill_id).to eq(learning_skill.id)
          expect(weekly_reflection.expectation).to eq("focus")
          expect(weekly_reflection.week_start_on).to eq(Date.new(2026, 11, 2))
          expect(weekly_reflection.reflected_at).to eq(Time.zone.local(2026, 11, 4, 12, 0, 0))
        end
      end
    end

    context "実感を選ばずに送った場合" do
      it "保存せず422を返す" do
        patch goal_weekly_reflection_review_path(goal, weekly_reflection), params: {
          weekly_reflection: { comment: "" }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(weekly_reflection.reload.feeling).to be_nil
        expect(weekly_reflection.reflected_at).to be_nil
      end
    end

    context "ひと言を201文字で送った場合" do
      it "保存せず422を返す" do
        patch goal_weekly_reflection_review_path(goal, weekly_reflection), params: {
          weekly_reflection: { feeling: "felt", comment: "あ" * 201 }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(weekly_reflection.reload.feeling).to be_nil
        expect(weekly_reflection.reflected_at).to be_nil
      end
    end

    context "他人の目標の場合" do
      it "保存せず404を返す" do
        other_reflection = create(:weekly_reflection)

        patch goal_weekly_reflection_review_path(other_reflection.goal, other_reflection), params: {
          weekly_reflection: valid_params
        }

        expect(response).to have_http_status(:not_found)
        expect(other_reflection.reload.feeling).to be_nil
      end
    end

    context "自分の目標URLに別の目標の週のIDを指定した場合" do
      it "保存せず404を返す" do
        another_goal = create(:goal, :completed, user: user)
        another_reflection = create(:weekly_reflection, goal: another_goal)

        patch goal_weekly_reflection_review_path(goal, another_reflection), params: {
          weekly_reflection: valid_params
        }

        expect(response).to have_http_status(:not_found)
        expect(another_reflection.reload.feeling).to be_nil
      end
    end

    context "完了した目標の場合" do
      let(:goal) { create(:goal, :completed, user: user) }

      it "変更せず、その週の画面へ303で戻して変更不可の文言を表示する" do
        patch goal_weekly_reflection_review_path(goal, weekly_reflection), params: { weekly_reflection: valid_params }

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_weekly_reflection_path(goal, weekly_reflection))
        expect(flash[:danger]).to eq("完了した目標では変更できません")
        expect(weekly_reflection.reload.feeling).to be_nil
      end
    end
  end

  describe "GET /goals/:goal_id/weekly_reflections/:weekly_reflection_id/review" do
    let(:weekly_reflection) do
      create(
        :weekly_reflection,
        goal: goal,
        learning_skill: learning_skill,
        week_start_on: Date.new(2026, 11, 2),
        feeling: "felt",
        reflected_at: Time.zone.local(2026, 11, 4, 12, 0, 0)
      )
    end

    context "他人の目標の場合" do
      it "404を返す" do
        other_reflection = create(:weekly_reflection)

        get goal_weekly_reflection_review_path(other_reflection.goal, other_reflection)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "自分の目標URLに別の目標の週のIDを指定した場合" do
      it "404を返す" do
        another_goal = create(:goal, :completed, user: user)
        another_reflection = create(:weekly_reflection, goal: another_goal)

        get goal_weekly_reflection_review_path(goal, another_reflection)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "実感を保存していない週の場合" do
      let(:weekly_reflection) do
        create(:weekly_reflection, goal: goal, learning_skill: learning_skill, week_start_on: Date.new(2026, 11, 2))
      end

      it "その週の画面へ303で移る" do
        get goal_weekly_reflection_review_path(goal, weekly_reflection)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_weekly_reflection_path(goal, weekly_reflection))
      end
    end

    context "完了した目標の、振り返り済みの週の場合" do
      let(:goal) { create(:goal, :completed, user: user) }

      it "200で結果の画面を表示する" do
        get goal_weekly_reflection_review_path(goal, weekly_reflection)

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
