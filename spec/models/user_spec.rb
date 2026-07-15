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
        user = build(:user, name: "テストユーザー")

        expect(user).to be_valid
      end
    end

    context "名前がない場合は無効となりエラーメッセージが表示される" do
      it "無効である" do
        user = build(:user, name: nil)

        expect(user).not_to be_valid
        expect(user.errors[:name]).to be_present
      end
    end

    context "名前が51文字の場合" do
      it "無効である" do
        user = build(:user, name: "あ" * 51)

        expect(user).not_to be_valid
      end
    end
  end

  describe "メールアドレスのバリデーション" do
    context "有効なメールアドレスの場合" do
      it "有効である" do
        expect(build(:user, email_address: "test@example.com")).to be_valid
      end
    end

    context "メールアドレスがない場合" do
      it "無効である" do
        expect(build(:user, email_address: nil)).not_to be_valid
      end
    end

    context "メールアドレスの形式が正しくない場合" do
      it "無効である" do
        expect(build(:user, email_address: "invalid-email")).not_to be_valid
      end
    end

    context "メールアドレスが256文字の場合" do
      it "無効である" do
        email_address = "a" * 244 + "@example.com"

        expect(build(:user, email_address: email_address)).not_to be_valid
      end
    end

    context "メールアドレスがすでに使われている場合" do
      it "大文字小文字が違っても無効である" do
        create(:user, email_address: "test@example.com")

        expect(build(:user, email_address: "TEST@EXAMPLE.COM")).not_to be_valid
      end
    end
  end

  describe "メールアドレスの正規化" do
    it "前後の空白を除去し、小文字に変換する" do
      user = build(:user, email_address: "  TEST@EXAMPLE.COM  ")

      expect(user.email_address).to eq("test@example.com")
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
