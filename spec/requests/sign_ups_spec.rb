require "rails_helper"

RSpec.describe "SignUps", type: :request do
  describe "POST /sign_up" do
    context "登録済みメールアドレスの場合" do
      let!(:registered_user) { create(:user, email_address: "registered@example.com") }

      it "登録状況を示す詳細エラーを表示せず、ユーザーを作成しない" do
        expect {
          post sign_up_path, params: {
            user: {
              name: "別のユーザー",
              email_address: registered_user.email_address.upcase,
              password: "Password123!",
              password_confirmation: "Password123!"
            }
          }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include(I18n.t("sign_ups.create.danger"))
        expect(response.body).not_to include("E-mailアドレスはすでに存在します")

        email_field = response.parsed_body.at_css('input[name="user[email_address]"]')

        expect(response.parsed_body.at_css("#email_address-error")).to be_nil
        expect(email_field["class"].split).not_to include("has-error")
        expect(email_field["aria-describedby"]).to be_nil
      end
    end

    context "メールアドレスの形式と名前が不正な場合" do
      it "メールアドレスの詳細エラーを表示せず、名前の詳細エラーは表示する" do
        post sign_up_path, params: {
          user: {
            name: "",
            email_address: "invalid-email",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body.at_css("#email_address-error")).to be_nil
        expect(response.parsed_body.at_css("#name-error")).to be_present

        name_field = response.parsed_body.at_css('input[name="user[name]"]')

        expect(name_field["class"].split).to include("has-error")
        expect(name_field["aria-describedby"]).to eq("name-error")
      end
    end
  end
end
