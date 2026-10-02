require "rails_helper"

RSpec.describe "LearningSkills", type: :request do
  describe "GET /learning_skills" do
    it "ログインユーザーの学習スキルだけを新しい順に表示する" do
      user = create(:user)
      sign_in(user)
      create(:learning_skill, user: user, name: "前からある工夫")
      create(:learning_skill, user: user, name: "最近の工夫")
      create(:learning_skill, name: "他の人の工夫")

      get learning_skills_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("最近の工夫", "前からある工夫")
      expect(response.body).not_to include("他の人の工夫")
      expect(response.body.index("最近の工夫")).to be < response.body.index("前からある工夫")
    end
  end

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
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(learning_skills_path)
      expect(flash[:success]).to eq("学習スキルを登録しました")

      follow_redirect!

      expect(response.body).to include("復習5分")
    end

    it "同じスキル名の場合は登録せず重複エラーを返す" do
      user = create(:user)
      create(:learning_skill, user: user, name: "復習5分")
      sign_in(user)

      before_count = user.learning_skills.count

      post learning_skills_path,
           params: { learning_skill: { name: "復習5分" } }

      expect(user.learning_skills.count).to eq(before_count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("同じ名前の学習スキルがすでにあります")
      expect(response.body).to include("復習5分")
    end
  end
end
