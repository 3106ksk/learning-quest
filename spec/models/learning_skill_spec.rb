require 'rails_helper'

RSpec.describe LearningSkill, type: :model do
  describe "バリデーション" do
    it "名前が空だと保存できない" do
      learning_skill = build(:learning_skill, name: "")

      expect(learning_skill).to be_invalid
      expect(learning_skill.errors[:name]).to be_present
    end

    it "名前が100文字なら保存できる" do
      learning_skill = build(:learning_skill, name: "あ" * 100)

      expect(learning_skill).to be_valid
    end

    it "名前が101文字だと保存できない" do
      learning_skill = build(:learning_skill, name: "あ" * 101)

      expect(learning_skill).to be_invalid
      expect(learning_skill.errors[:name]).to be_present
    end
  end

  describe "名前の正規化と一意性" do
    it "名前の前後の空白を除去して保存する" do
      learning_skill = create(:learning_skill, name: "  復習5分  ")

      expect(learning_skill.reload.name).to eq("復習5分")
    end

    it "find_byの検索値でも前後の空白を除去する" do
      learning_skill = create(:learning_skill, name: "復習5分")

      expect(LearningSkill.find_by(name: "  復習5分  ")).to eq(learning_skill)
    end

    it "同じ利用者は前後の空白だけが違う同名の学習スキルを作成できない" do
      user = create(:user)
      create(:learning_skill, user: user, name: "復習5分")
      duplicate = build(:learning_skill, user: user, name: "  復習5分  ")

      expect(duplicate).to be_invalid
      expect(duplicate.errors[:name]).to be_present
    end

    it "別の利用者なら同じ名前の学習スキルを作成できる" do
      create(:learning_skill, name: "復習5分")
      learning_skill = build(:learning_skill, name: "復習5分")

      expect(learning_skill).to be_valid
    end
  end
end
