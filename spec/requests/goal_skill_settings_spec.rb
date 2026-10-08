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

  describe "POST /goals/:goal_id/skill_settings" do
    let(:goal) { create(:goal, user: user) }
    let(:learning_skill) { create(:learning_skill, user: user) }

    context "進行中の目標に未設定の学習スキルを設定する場合" do
      it "設定行を1件作り、303で設定画面へ戻る" do
        expect {
          post goal_skill_settings_path(goal), params: { learning_skill_id: learning_skill.id }
        }.to change(GoalSkillSetting, :count).by(1)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_skill_settings_path(goal))
        expect(flash).to be_empty
      end
    end

    context "同じ学習スキルの設定を2回送る場合" do
      it "設定行は1件のまま、どちらも303で設定画面へ戻る" do
        2.times do
          post goal_skill_settings_path(goal), params: { learning_skill_id: learning_skill.id }

          expect(response).to have_http_status(:see_other)
          expect(response).to redirect_to(goal_skill_settings_path(goal))
          expect(flash).to be_empty
        end

        expect(goal.goal_skill_settings.count).to eq(1)
      end
    end

    context "他ユーザーの学習スキルを指定した場合" do
      it "設定行を作らず404を返す" do
        other_skill = create(:learning_skill)

        expect {
          post goal_skill_settings_path(goal), params: { learning_skill_id: other_skill.id }
        }.not_to change(GoalSkillSetting, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "他ユーザーの目標を指定した場合" do
      it "設定行を作らず404を返す" do
        other_goal = create(:goal)

        expect {
          post goal_skill_settings_path(other_goal), params: { learning_skill_id: learning_skill.id }
        }.not_to change(GoalSkillSetting, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "完了した目標の場合" do
      it "設定行を作らず、目標詳細へ303で戻して変更不可の文言を表示する" do
        completed_goal = create(:goal, :completed, user: user)

        expect {
          post goal_skill_settings_path(completed_goal), params: { learning_skill_id: learning_skill.id }
        }.not_to change(GoalSkillSetting, :count)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_path(completed_goal))
        expect(flash[:danger]).to eq("完了した目標の学習スキルは変更できません")
      end
    end

    context "設定時にDBの一意制約に当たった場合" do
      it "303で設定画面へ戻る" do
        allow_any_instance_of(GoalSkillSetting).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)

        post goal_skill_settings_path(goal), params: { learning_skill_id: learning_skill.id }

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_skill_settings_path(goal))
        expect(flash).to be_empty
      end
    end
  end

  describe "DELETE /goals/:goal_id/skill_settings/:id" do
    let(:goal) { create(:goal, user: user) }

    context "進行中の目標に設定行がある場合" do
      it "設定行だけを消し、学習スキルと学習記録を残して303で設定画面へ戻る" do
        skill = create(:learning_skill, user: user)
        setting = create(:goal_skill_setting, goal: goal, learning_skill: skill)
        study_record = create(:study_record, user: user, goal: goal, learning_skill: skill)

        expect {
          delete goal_skill_setting_path(goal, setting)
        }.to change(GoalSkillSetting, :count).by(-1)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_skill_settings_path(goal))
        expect(flash).to be_empty
        expect(LearningSkill.exists?(skill.id)).to be(true)
        expect(StudyRecord.exists?(study_record.id)).to be(true)
      end
    end

    context "設定行が既に存在しない場合" do
      it "303で設定画面へ戻る" do
        delete goal_skill_setting_path(goal, 0)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_skill_settings_path(goal))
        expect(flash).to be_empty
      end
    end

    context "他ユーザーの目標を指定した場合" do
      it "設定行を消さず404を返す" do
        other_goal = create(:goal)
        setting = create(:goal_skill_setting, goal: other_goal)

        expect {
          delete goal_skill_setting_path(other_goal, setting)
        }.not_to change(GoalSkillSetting, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "自分の目標URLに別の目標の設定行IDを指定した場合" do
      it "設定行を消さず303で設定画面へ戻る" do
        another_goal = create(:goal)
        setting = create(:goal_skill_setting, goal: another_goal)

        expect {
          delete goal_skill_setting_path(goal, setting)
        }.not_to change(GoalSkillSetting, :count)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_skill_settings_path(goal))
        expect(flash).to be_empty
      end
    end

    context "完了した目標の場合" do
      it "設定行を消さず、目標詳細へ303で戻して変更不可の文言を表示する" do
        completed_goal = create(:goal, :completed, user: user)
        setting = create(:goal_skill_setting, goal: completed_goal)

        expect {
          delete goal_skill_setting_path(completed_goal, setting)
        }.not_to change(GoalSkillSetting, :count)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(goal_path(completed_goal))
        expect(flash[:danger]).to eq("完了した目標の学習スキルは変更できません")
      end
    end
  end
end
