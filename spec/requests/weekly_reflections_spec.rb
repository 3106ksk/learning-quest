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

  describe "GET /goals/:goal_id/weekly_reflections" do
    context "進行中の目標の場合" do
      it "200で一覧を表示する" do
        get goal_weekly_reflections_path(goal)

        expect(response).to have_http_status(:ok)
      end
    end

    context "他人の目標の場合" do
      it "404を返す" do
        other_goal = create(:goal)

        get goal_weekly_reflections_path(other_goal)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "完了した目標の場合" do
      let(:goal) { create(:goal, :completed, user: user) }

      it "200で一覧を表示する" do
        get goal_weekly_reflections_path(goal)

        expect(response).to have_http_status(:ok)
      end
    end

    context "前の週の分がまだ振り返っていない場合" do
      it "前の週の案内と、その週の画面への「この週を振り返る」を表示する" do
        travel_to Time.zone.local(2026, 11, 4, 12, 0, 0) do
          previous_week = create(:weekly_reflection, goal: goal, learning_skill: learning_skill, week_start_on: Date.new(2026, 10, 26))

          get goal_weekly_reflections_path(goal)

          expect(response).to have_http_status(:ok)
          document = response.parsed_body
          review_links = document.css("a").select { |link| link.text.strip == "この週を振り返る" }.map { |link| link["href"] }
          expect(document.text).to include("10/26〜11/1 の週を、まだ振り返っていません")
          expect(review_links).to eq([ goal_weekly_reflection_path(goal, previous_week) ])
        end
      end
    end

    context "前の週の案内を出さない場合" do
      it "前の週が振り返り済みなら、案内を出さない" do
        travel_to Time.zone.local(2026, 11, 4, 12, 0, 0) do
          create(
            :weekly_reflection,
            goal: goal,
            learning_skill: learning_skill,
            week_start_on: Date.new(2026, 10, 26),
            feeling: "felt",
            reflected_at: Time.zone.local(2026, 10, 31, 12, 0, 0)
          )

          get goal_weekly_reflections_path(goal)

          expect(response).to have_http_status(:ok)
          document = response.parsed_body
          review_links = document.css("a").select { |link| link.text.strip == "この週を振り返る" }.map { |link| link["href"] }
          expect(document.text).not_to include("まだ振り返っていません")
          expect(review_links).to eq([])
        end
      end

      it "前の週の分が無ければ、案内を出さない" do
        travel_to Time.zone.local(2026, 11, 4, 12, 0, 0) do
          get goal_weekly_reflections_path(goal)

          expect(response).to have_http_status(:ok)
          document = response.parsed_body
          review_links = document.css("a").select { |link| link.text.strip == "この週を振り返る" }.map { |link| link["href"] }
          expect(document.text).not_to include("まだ振り返っていません")
          expect(review_links).to eq([])
        end
      end

      it "2週前だけまだ振り返っていなければ、案内を出さない" do
        travel_to Time.zone.local(2026, 11, 4, 12, 0, 0) do
          create(:weekly_reflection, goal: goal, learning_skill: learning_skill, week_start_on: Date.new(2026, 10, 19))

          get goal_weekly_reflections_path(goal)

          expect(response).to have_http_status(:ok)
          document = response.parsed_body
          review_links = document.css("a").select { |link| link.text.strip == "この週を振り返る" }.map { |link| link["href"] }
          expect(document.text).not_to include("まだ振り返っていません")
          expect(review_links).to eq([])
        end
      end
    end

    context "今週の分が無い場合" do
      it "決める画面へのリンクを表示する" do
        travel_to Time.zone.local(2026, 11, 4, 12, 0, 0) do
          get goal_weekly_reflections_path(goal)

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body.at_css("a[href='#{new_goal_weekly_reflection_path(goal)}']")&.text&.strip).to eq("今週の学習スキルと期待する変化を決める")
        end
      end
    end

    context "今週の分がある場合" do
      it "今週の学習スキル名と、今週の画面への「この週を振り返る」を表示し、今週はこれまでの週に並べない" do
        travel_to Time.zone.local(2026, 11, 4, 12, 0, 0) do
          current_week = create(:weekly_reflection, goal: goal, learning_skill: learning_skill, week_start_on: Date.new(2026, 11, 2))

          get goal_weekly_reflections_path(goal)

          expect(response).to have_http_status(:ok)
          document = response.parsed_body
          review_links = document.css("a").select { |link| link.text.strip == "この週を振り返る" }.map { |link| link["href"] }
          past_week_links = document.css("section[aria-labelledby='past-weeks-title'] li a").map { |link| link["href"] }
          expect(document.text).to include(learning_skill.name)
          expect(review_links).to eq([ goal_weekly_reflection_path(goal, current_week) ])
          expect(past_week_links).to eq([])
        end
      end
    end

    context "これまでの週が複数ある場合" do
      it "週の新しい順に並べる" do
        travel_to Time.zone.local(2026, 11, 4, 12, 0, 0) do
          older_week = create(:weekly_reflection, goal: goal, learning_skill: learning_skill, week_start_on: Date.new(2026, 10, 19))
          newer_week = create(:weekly_reflection, goal: goal, learning_skill: learning_skill, week_start_on: Date.new(2026, 10, 26))

          get goal_weekly_reflections_path(goal)

          expect(response).to have_http_status(:ok)
          past_week_links = response.parsed_body.css("section[aria-labelledby='past-weeks-title'] li a").map { |link| link["href"] }
          expect(past_week_links).to eq([
            goal_weekly_reflection_path(goal, newer_week),
            goal_weekly_reflection_path(goal, older_week)
          ])
        end
      end
    end

    context "これまでの週が0件の場合" do
      it "「これまでの週は、まだありません」を表示する" do
        travel_to Time.zone.local(2026, 11, 4, 12, 0, 0) do
          get goal_weekly_reflections_path(goal)

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body.at_css("section[aria-labelledby='past-weeks-title']")&.text).to include("これまでの週は、まだありません")
        end
      end
    end

    context "完了した目標で、今週の分とまだ振り返っていない前の週の分がある場合" do
      let(:goal) { create(:goal, :completed, user: user) }

      it "今週も行に並べ、案内・今週の枠・決めるボタンを出さない" do
        travel_to Time.zone.local(2026, 11, 4, 12, 0, 0) do
          previous_week = create(:weekly_reflection, goal: goal, learning_skill: learning_skill, week_start_on: Date.new(2026, 10, 26))
          current_week = create(:weekly_reflection, goal: goal, learning_skill: learning_skill, week_start_on: Date.new(2026, 11, 2))

          get goal_weekly_reflections_path(goal)

          expect(response).to have_http_status(:ok)
          document = response.parsed_body
          review_links = document.css("a").select { |link| link.text.strip == "この週を振り返る" }.map { |link| link["href"] }
          past_week_links = document.css("section[aria-labelledby='past-weeks-title'] li a").map { |link| link["href"] }
          expect(past_week_links).to eq([
            goal_weekly_reflection_path(goal, current_week),
            goal_weekly_reflection_path(goal, previous_week)
          ])
          expect(review_links).to eq([])
          expect(document.at_css("a[href='#{new_goal_weekly_reflection_path(goal)}']")).to be_nil
          expect(document.text).not_to include("まだ振り返っていません")
          expect(document.text).not_to include("今週（ここまで）")
        end
      end
    end

    context "振り返り済みの週とまだの週がある場合" do
      it "振り返り済みの行は結果の画面へ、まだの行はその週の画面へ移る" do
        travel_to Time.zone.local(2026, 11, 4, 12, 0, 0) do
          reflected_week = create(
            :weekly_reflection,
            goal: goal,
            learning_skill: learning_skill,
            week_start_on: Date.new(2026, 10, 19),
            feeling: "felt",
            reflected_at: Time.zone.local(2026, 10, 24, 12, 0, 0)
          )
          unreflected_week = create(:weekly_reflection, goal: goal, learning_skill: learning_skill, week_start_on: Date.new(2026, 10, 26))

          get goal_weekly_reflections_path(goal)

          expect(response).to have_http_status(:ok)
          past_week_links = response.parsed_body.css("section[aria-labelledby='past-weeks-title'] li a").map { |link| link["href"] }
          expect(past_week_links).to eq([
            goal_weekly_reflection_path(goal, unreflected_week),
            goal_weekly_reflection_review_path(goal, reflected_week)
          ])
        end
      end
    end
  end

  describe "GET /goals/:goal_id/weekly_reflections/new" do
    context "進行中の目標に新しく週のリフレクションを作成する場合" do
      it "200で入力フォームを表示する" do
        learning_skill

        get new_goal_weekly_reflection_path(goal)

        expect(response).to have_http_status(:ok)
        form = response.parsed_body.at_css("form[action='#{goal_weekly_reflections_path(goal)}'][method='post']")
        expect(form).to be_present
        expect(form.at_css("input[type='radio'][name='weekly_reflection[learning_skill_id]'][value='#{learning_skill.id}']")).to be_present
      end
    end

    context "既に週のリフレクションが存在する場合" do
      it "その週の画面へ移る" do
        travel_to Time.zone.local(2026, 11, 4, 12, 0, 0) do
          weekly_reflection = create(:weekly_reflection, goal: goal, learning_skill: learning_skill)

          get new_goal_weekly_reflection_path(goal)

          expect(response).to redirect_to(goal_weekly_reflection_path(goal, weekly_reflection))
        end
      end
    end

    context "完了した目標の場合" do
      let(:goal) { create(:goal, :completed, user: user) }

      it "目標詳細へ303で戻して完了済みの文言を表示する" do
        get new_goal_weekly_reflection_path(goal)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_path(goal))
        expect(flash[:danger]).to eq("この目標は既に完了しています")
      end
    end

    context "他人の目標の場合" do
      it "404を返す" do
        other_goal = create(:goal)

        get new_goal_weekly_reflection_path(other_goal)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "学習スキルの使用設定が0件の場合" do
      it "設定画面へのリンクと押せない送信ボタンを表示する" do
        get new_goal_weekly_reflection_path(goal)

        expect(response).to have_http_status(:ok)
        document = response.parsed_body
        expect(document.at_css("a[href='#{goal_skill_settings_path(goal)}']")&.text).to eq("この目標で使う学習スキルを選ぶ →")
        expect(document.at_css("input[type='submit'][disabled]")).to be_present
      end
    end
  end

  describe "GET /goals/:goal_id/weekly_reflections/:id" do
    context "他人の目標の場合" do
      it "404を返す" do
        weekly_reflection = create(:weekly_reflection)

        get goal_weekly_reflection_path(weekly_reflection.goal, weekly_reflection)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "自分の目標URLに別の目標の週のIDを指定した場合" do
      it "404を返す" do
        another_goal = create(:goal, :completed, user: user)
        weekly_reflection = create(:weekly_reflection, goal: another_goal)

        get goal_weekly_reflection_path(goal, weekly_reflection)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "完了した目標の場合" do
      let(:goal) { create(:goal, :completed, user: user) }

      it "200でその週の画面を表示する" do
        weekly_reflection = create(:weekly_reflection, goal: goal, learning_skill: learning_skill)

        get goal_weekly_reflection_path(goal, weekly_reflection)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /goals/:goal_id/weekly_reflections" do
    context "学習スキルを選択せずにフォーム送信をした場合" do
      it "保存せず422で入力フォームを再表示し、面1にエラーを1文表示する" do
        learning_skill

        expect {
          post goal_weekly_reflections_path(goal), params: {
            weekly_reflection: { learning_skill_id: "", expectation: "focus", expectation_note: "" }
          }
        }.not_to change(WeeklyReflection, :count)

        expect(response).to have_http_status(:unprocessable_content)
        skill_fieldset = response.parsed_body.css("fieldset").find do |fieldset|
          fieldset.at_css("input[name='weekly_reflection[learning_skill_id]']")
        end
        expect(skill_fieldset).to be_present
        errors = skill_fieldset.css(".group-error")
        expect(errors.size).to eq(1)
        expect(errors.first.text.strip).to eq("今週の学習スキルを選んでください")
      end
    end

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
