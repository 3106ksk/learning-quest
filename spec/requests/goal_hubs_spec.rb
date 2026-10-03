require "rails_helper"

RSpec.describe "Goal hubs", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe "GET /goal_hub" do
    context "進行中の目標がある場合" do
      it "目標名と目標詳細へのリンクを表示する" do
        goal = create(:goal, user: user, name: "Railsを習得する")

        get goal_hub_path

        expect(response).to have_http_status(:ok)

        document = response.parsed_body
        expect(document.text).to include(goal.name)
        expect(document.at_css("a[href='#{goal_path(goal)}']").text).to eq("詳細")
      end
    end

    context "完了済み目標だけの場合" do
      it "空状態と目標設定へのリンクを表示する" do
        create(:goal, :completed, user: user)

        get goal_hub_path

        expect(response).to have_http_status(:ok)

        document = response.parsed_body
        expect(document.text).to include("進行中の目標はありません")
        expect(document.at_css("a[href='#{new_goal_path}']").text).to eq("目標を設定する")
      end
    end

    context "目標がない場合" do
      it "空状態と目標設定へのリンクを表示する" do
        get goal_hub_path

        expect(response).to have_http_status(:ok)

        document = response.parsed_body
        expect(document.text).to include("進行中の目標はありません")
        expect(document.at_css("a[href='#{new_goal_path}']").text).to eq("目標を設定する")
      end
    end
  end
end
