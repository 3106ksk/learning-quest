require "rails_helper"

RSpec.describe "Goal skill settings", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe "GET /goals/:goal_id/skill_settings" do
    context "進行中の目標の場合" do
      it "自分の学習スキルだけを表示する" do
        goal = create(:goal, user: user)
        create(:learning_skill, user: user, name: "自分の学習スキル")
        create(:learning_skill, name: "他ユーザーの学習スキル")

        get goal_skill_settings_path(goal)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("自分の学習スキル")
        expect(response.body).not_to include("他ユーザーの学習スキル")
      end
    end

    context "完了した目標の場合" do
      it "学習スキル設定画面URLを直接開くと、目標詳細へ303で戻り、変更不可のフラッシュを表示する" do
        goal = create(:goal, :completed, user: user)

        get goal_skill_settings_path(goal)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_path(goal))
        expect(flash[:danger]).to eq("完了した目標の学習スキルは変更できません")
      end
    end
  end
end
