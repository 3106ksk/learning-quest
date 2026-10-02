require "rails_helper"

RSpec.describe "LearningSkills", type: :request do
  describe "POST /learning_skills" do
    it "他ユーザーと同じ名前でもログインユーザーの学習スキルとして登録できる" do
      other_user = create(:user)
      create(:learning_skill, user: other_user, name: "復習5分")
      user = create(:user)
      sign_in(user)

      before_count = user.learning_skills.count

      post learning_skills_path,
           params: { learning_skill: { name: "復習5分" } }

      expect(user.learning_skills.count).to eq(before_count + 1)
      expect(user.learning_skills.last.name).to eq("復習5分")
      expect(response).to redirect_to(new_learning_skill_path)
      expect(flash[:success]).to eq("学習スキルを登録しました")
    end

    it "自分と同じ名前は登録せず重複エラーを返す" do
      user = create(:user)
      create(:learning_skill, user: user, name: "復習5分")
      sign_in(user)

      before_count = user.learning_skills.count

      post learning_skills_path,
           params: { learning_skill: { name: "復習5分" } }

      expect(user.learning_skills.count).to eq(before_count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("同じ名前の学習スキルがすでにあります")
    end
  end
end
