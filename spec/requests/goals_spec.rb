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
end
