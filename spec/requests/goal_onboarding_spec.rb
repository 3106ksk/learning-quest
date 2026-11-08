require "rails_helper"

RSpec.describe "Goal onboarding", type: :request do
  describe "POST /users" do
    it "ユーザー作成後は、目標設定画面へ遷移する" do
      expect {
        post user_registration_path, params: {
          user: {
            account_name: "テストユーザー",
            email: "new-user@example.com",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(new_goal_path)
    end
  end
end
