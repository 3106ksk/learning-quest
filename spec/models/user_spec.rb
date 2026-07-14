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
end
