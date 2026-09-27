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
end
