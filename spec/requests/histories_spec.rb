require 'rails_helper'

RSpec.describe "Histories", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:focus_option) do
    FocusOption.create!(
      result_code: "focused",
      label: "集中できた",
      point: 2,
      position: 1
    )
  end
  let(:challenge_option) do
    ChallengeOption.create!(
      result_code: "challenged",
      label: "挑戦できた",
      point: 3,
      position: 1
    )
  end

  before do
    sign_in(user)
  end

  describe "GET /histories/:id" do
    context "ログインユーザーの評価済み学習記録の場合" do
      it "学習履歴詳細画面を表示する" do
        study_record = create_evaluated_record(user: user)

        get history_path(study_record)

        expect(response).to have_http_status(:ok)
      end
    end

    context "他のユーザーの評価済み学習記録の場合" do
      it "学習履歴一覧画面へ戻り、記録が見つからないことを通知する" do
        study_record = create_evaluated_record(user: other_user)

        get history_path(study_record)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(histories_path)

        follow_redirect!

        expect(response.body).to include(I18n.t("histories.show.not_found"))
      end
    end

    context "ログインユーザーが未評価学習記録をURLで直接指定した場合" do
      it "学習履歴一覧画面へ戻る" do
        study_record = StudyRecord.create!(
          user: user,
          planned_minutes: 25,
          activity: "評価前の学習",
          started_at: Time.current,
          status: :awaiting_evaluation
        )

        get history_path(study_record)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(histories_path)
      end
    end
  end

  def create_evaluated_record(user:)
    StudyRecord.create!(
      user: user,
      planned_minutes: 25,
      activity: "RSpecの学習",
      started_at: Time.current,
      status: :evaluated,
      rank: :a,
      actual_seconds: 20.minutes
    ).tap do |study_record|
      Evaluation.create!(
        study_record: study_record,
        focus_option: focus_option,
        challenge_option: challenge_option
      )
    end
  end

  def sign_in(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "Password123!"
    }
  end
end
