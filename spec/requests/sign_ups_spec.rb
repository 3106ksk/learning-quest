require "rails_helper"

RSpec.describe "User registrations", type: :request do
  describe "POST /users" do
    context "登録済みメールアドレスの場合" do
      let!(:registered_user) { create(:user, email: "registered@example.com") }

      it "ユーザーを作成せず、登録エラーを表示する" do
        expect {
          post user_registration_path, params: {
            user: {
              account_name: "別のユーザー",
              email: registered_user.email.upcase,
              password: "Password123!",
              password_confirmation: "Password123!"
            }
          }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_content)

        email_field = response.parsed_body.at_css('input[name="user[email]"]')

        expect(response.parsed_body.at_css("#error_explanation")).to be_present
        expect(email_field).to be_present
      end
    end

    context "メールアドレスの形式とアカウント名が不正な場合" do
      it "登録エラーを表示する" do
        post user_registration_path, params: {
          user: {
            account_name: "",
            email: "invalid-email",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }

        expect(response).to have_http_status(:unprocessable_content)

        account_name_field = response.parsed_body.at_css('input[name="user[account_name]"]')
        email_field = response.parsed_body.at_css('input[name="user[email]"]')

        expect(response.parsed_body.at_css("#error_explanation")).to be_present
        expect(account_name_field).to be_present
        expect(email_field).to be_present
      end
    end
  end
end
