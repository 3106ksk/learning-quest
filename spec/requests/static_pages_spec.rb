require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "GET /" do
    context "未ログインの場合" do
      it "LPを表示する" do
        get root_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t("static_pages.home.headline"))
      end
    end

    context "ログイン済みの場合" do
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it "学習開始画面へ遷移する" do
        get root_path

        expect(response).to redirect_to(new_study_record_path)
      end
    end
  end

  def sign_in(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "Password123!"
    }
  end
end
