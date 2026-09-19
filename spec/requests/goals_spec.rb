require "rails_helper"

RSpec.describe "Goals", type: :request do
  describe "GET /goals/new" do
    context "未ログインの場合" do
      it "ログイン画面へ遷移する" do
        get new_goal_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it "目標設定画面を表示する" do
        get new_goal_path

        expect(response).to have_http_status(:ok)
      end

      it "目標名フォームを表示する" do
        get new_goal_path

        form = response.parsed_body.at_css("form[action='#{goals_path}']")

        expect(form).to be_present
        expect(form.at_css('input[name="goal[name]"]')).to be_present
      end
    end
  end

  describe "POST /goals" do
    let(:user) { create(:user) }
    let(:valid_params) do
      {
        goal: {
          name: "Railsを習得する"
        }
      }
    end

    before do
      sign_in(user)
    end

    context "有効な目標名の場合" do
      it "ログインユーザーの進行中の目標を1件作成する" do
        expect {
          post goals_path, params: valid_params
        }.to change { user.goals.active.count }.from(0).to(1)
      end

      it "学習開始画面へ遷移し、成功メッセージを設定する" do
        post goals_path, params: valid_params

        expect(response).to redirect_to(new_study_record_path)
        expect(flash[:success]).to be_present
      end
    end

    context "目標名が空の場合" do
      it "目標を作成せず、目標設定画面を再表示する" do
        expect {
          post goals_path, params: { goal: { name: "" } }
        }.not_to change(Goal, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body.at_css('input[name="goal[name]"]')).to be_present
      end
    end

    context "目標名が101文字の場合" do
      it "目標を作成しない" do
        expect {
          post goals_path, params: { goal: { name: "あ" * 101 } }
        }.not_to change(Goal, :count)
      end
    end

    context "進行中の目標がすでにある場合" do
      before do
        create(:goal, user: user)
      end

      it "新しい目標を作成しない" do
        expect {
          post goals_path, params: valid_params
        }.not_to change(Goal, :count)
      end
    end

    context "別ユーザーのuser_idが送信された場合" do
      it "user_idを無視し、ログインユーザーの目標を作成する" do
        other_user = create(:user)
        params = {
          goal: valid_params[:goal].merge(user_id: other_user.id)
        }

        expect {
          post goals_path, params: params
        }.to change { user.goals.active.count }.by(1)

        expect(other_user.goals.count).to eq(0)
        expect(user.goals.active.last.user).to eq(user)
      end
    end
  end

  describe "GET /goals (index)" do
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    it "ログインユーザーの目標だけを表示する" do
      own_goal = create(:goal, user: user, name: "自分の目標")
      other_goal = create(:goal, name: "他ユーザーの目標")

      get goals_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(own_goal.name)
      expect(response.body).not_to include(other_goal.name)
    end
  end

  describe "GET /goals/:id (show)" do
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    context "自分の取り組み中の目標の場合" do
      it "指定した目標名を表示する" do
        goal = create(:goal, user: user, name: "Railsを習得する")

        get goal_path(goal)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(goal.name)
      end
    end

    context "他ユーザーの目標の場合" do
      it "目標の内容を表示しない" do
        other_goal = create(:goal, name: "他ユーザーの目標")

        get goal_path(other_goal)

        expect(response).to have_http_status(:not_found)
        expect(response.body).not_to include(other_goal.name)
      end
    end
  end

  describe "GET /goals/:id/edit (edit)" do
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    context "自分の取り組み中の目標の場合" do
      it "Turbo Frame内に編集フォームを表示する" do
        goal = create(:goal, user: user)
        frame_id = ActionView::RecordIdentifier.dom_id(goal)

        get edit_goal_path(goal)

        expect(response).to have_http_status(:ok)

        frame = response.parsed_body.at_css("turbo-frame##{frame_id}")
        expect(frame).to be_present
        expect(frame.at_css("form[action='#{goal_path(goal)}']")).to be_present
        expect(frame.at_css('input[name="goal[name]"]')).to be_present
      end
    end

    context "自分の完了済み目標の場合" do
      it "目標ページへリダイレクトする" do
        goal = create(:goal, :completed, user: user)

        get edit_goal_path(goal)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_path(goal))
      end
    end

    context "他ユーザーの目標の場合" do
      it "404を返す" do
        other_goal = create(:goal)

        get edit_goal_path(other_goal)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /goals/:id (update)" do
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    context "有効な目標名の場合" do
      it "取り組み中の目標名を更新し、目標ページへリダイレクトする" do
        goal = create(:goal, user: user, name: "変更前の目標")

        expect {
          patch goal_path(goal), params: { goal: { name: "変更後の目標" } }
        }.to change { goal.reload.name }
          .from("変更前の目標")
          .to("変更後の目標")

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_path(goal))
      end
    end

    context "目標名が101文字の場合" do
      it "目標名を変更せず、入力値とエラーを再表示する" do
        goal = create(:goal, user: user, name: "変更前の目標")
        invalid_name = "あ" * 101

        expect {
          patch goal_path(goal), params: { goal: { name: invalid_name } }
        }.not_to change { goal.reload.name }

        expect(response).to have_http_status(:unprocessable_content)

        frame_id = ActionView::RecordIdentifier.dom_id(goal)
        frame = response.parsed_body.at_css("turbo-frame##{frame_id}")
        expect(frame).to be_present
        expect(frame.text).to include("100文字")

        input = frame.at_css('input[name="goal[name]"]')
        expect(input["value"]).to eq(invalid_name)
      end
    end

    context "自分の完了済み目標の場合" do
      it "目標名を変更せず、目標ページへリダイレクトする" do
        goal = create(:goal, :completed, user: user, name: "完了済みの目標")

        expect {
          patch goal_path(goal), params: { goal: { name: "変更後の目標" } }
        }.not_to change { goal.reload.name }

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_path(goal))
      end
    end

    context "他ユーザーの目標の場合" do
      it "目標名を変更せず、404を返す" do
        other_goal = create(:goal, name: "他ユーザーの目標")

        expect {
          patch goal_path(other_goal), params: { goal: { name: "不正な変更" } }
        }.not_to change { other_goal.reload.name }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
