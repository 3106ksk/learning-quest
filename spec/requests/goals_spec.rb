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
end
