require 'rails_helper'

RSpec.describe User, type: :model do
  it "有効なユーザーを生成できる" do
    user = create(:user)

    expect(user).to be_persisted
    expect(user).to be_valid
  end

  describe "名前のバリデーション" do
    context "名前がある場合" do
      it "有効である" do
        user = build(:user, account_name: "テストユーザー")

        expect(user).to be_valid
      end
    end

    context "名前がない場合は無効となりエラーメッセージが表示される" do
      it "無効である" do
        user = build(:user, account_name: nil)

        expect(user).not_to be_valid
        expect(user.errors[:account_name]).to be_present
      end
    end

    context "名前が51文字の場合" do
      it "無効である" do
        user = build(:user, account_name: "あ" * 51)

        expect(user).not_to be_valid
      end
    end
  end

  describe "メールアドレスのバリデーション" do
    context "有効なメールアドレスの場合" do
      it "有効である" do
        expect(build(:user, email: "test@example.com")).to be_valid
      end
    end

    context "メールアドレスがない場合" do
      it "無効である" do
        expect(build(:user, email: nil)).not_to be_valid
      end
    end

    context "メールアドレスの形式が正しくない場合" do
      it "無効である" do
        invalid_email_addresses = [
          "user",
          "user@example",
          "user@ example.com",
          "user@example,com"
        ]

        invalid_email_addresses.each do |email|
          expect(build(:user, email: email)).not_to be_valid,
            "#{email.inspect} は無効である必要があります"
        end
      end
    end

    context "メールアドレスが256文字の場合" do
      it "無効である" do
        email = "a" * 244 + "@example.com"

        expect(build(:user, email: email)).not_to be_valid
      end
    end

    context "メールアドレスがすでに使われている場合" do
      it "大文字小文字が違っても無効である" do
        create(:user, email: "test@example.com")

        expect(build(:user, email: "TEST@EXAMPLE.COM")).not_to be_valid
      end
    end
  end

  describe "メールアドレスの正規化" do
    it "前後の空白を除去し、小文字に変換する" do
      user = build(:user, email: "  TEST@EXAMPLE.COM  ")

      expect(user.email).to eq("test@example.com")
    end
  end

  describe "パスワードのバリデーション" do
    context "パスワードがない場合" do
      it "無効である" do
        expect(build(:user, password: nil, password_confirmation: nil)).not_to be_valid
      end
    end

    context "パスワード確認が一致しない場合" do
      it "無効である" do
        user = build(
          :user,
          password: "Password123!",
          password_confirmation: "DifferentPassword123!"
        )

        expect(user).not_to be_valid
      end
    end

    context "正しいパスワードの場合" do
      it "認証できる" do
        user = create(:user, password: "Password123!", password_confirmation: "Password123!")

        expect(user.authenticate("Password123!")).to eq(user)
      end
    end

    context "誤ったパスワードの場合" do
      it "認証できない" do
        user = create(:user, password: "Password123!", password_confirmation: "Password123!")

        expect(user.authenticate("WrongPassword123!")).to be(false)
      end
    end
  end

  describe "セッションとの関連" do
    it "ユーザーを削除すると、紐づくセッションも削除される" do
      user = create(:user)
      session = user.sessions.create!

      expect { user.destroy }.to change(Session, :count).by(-1)
      expect(Session.exists?(session.id)).to be_falsey
    end
  end
end
