require 'rails_helper'

RSpec.describe "Evaluations", type: :request do
  let(:user) { create(:user) }
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
  let(:study_record) do
    StudyRecord.create!(
      user: user,
      planned_minutes: 25,
      activity: "RSpecの学習",
      started_at: Time.current,
      status: study_record_status
    )
  end
  let(:evaluation_params) do
    {
      evaluation: {
        focus_option_id: focus_option.id,
        challenge_option_id: challenge_option.id
      }
    }
  end

  before do
    sign_in(user)
  end

  describe "GET /study_records/:study_record_id/evaluation/new" do
    context "学習記録が評価待ちの場合" do
      let(:study_record_status) { :awaiting_evaluation }

      it "評価入力画面を表示する" do
        get new_study_record_evaluation_path(study_record)

        expect(response).to have_http_status(:ok)
      end
    end

    context "学習記録が評価済みの場合" do
      let(:study_record_status) { :evaluated }

      it "ホーム画面へ遷移する" do
        get new_study_record_evaluation_path(study_record)

        expect(response).to redirect_to(home_path)
        expect(response).to have_http_status(:see_other)
      end
    end

    [ :running, :paused ].each do |status|
      context "学習記録が#{status}の場合" do
        let(:study_record_status) { status }

        it "学習記録のshow画面へ遷移する" do
          get new_study_record_evaluation_path(study_record)

          expect(response).to redirect_to(study_record_path(study_record))
          expect(response).to have_http_status(:see_other)
        end
      end
    end
  end

  describe "POST /study_records/:study_record_id/evaluation" do
    context "学習記録が評価待ちの場合" do
      let(:study_record_status) { :awaiting_evaluation }

      it "評価を保存して評価済みに変更する" do
        expect {
          post study_record_evaluation_path(study_record), params: evaluation_params
        }.to change(Evaluation, :count).by(1)

        expect(study_record.reload).to be_evaluated
        expect(response).to redirect_to(home_path)
        expect(response).to have_http_status(:see_other)
      end
    end

    context "学習記録が評価済みの場合" do
      let(:study_record_status) { :evaluated }

      it "評価を保存せずホーム画面へ遷移する" do
        expect {
          post study_record_evaluation_path(study_record), params: evaluation_params
        }.not_to change(Evaluation, :count)

        expect(response).to redirect_to(home_path)
        expect(response).to have_http_status(:see_other)
      end
    end

    [ :running, :paused ].each do |status|
      context "学習記録が#{status}の場合" do
        let(:study_record_status) { status }

        it "評価を保存せず学習記録のshow画面へ遷移する" do
          expect {
            post study_record_evaluation_path(study_record), params: evaluation_params
          }.not_to change(Evaluation, :count)

          expect(response).to redirect_to(study_record_path(study_record))
          expect(response).to have_http_status(:see_other)
        end
      end
    end
  end

  def sign_in(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "Password123!"
    }
  end
end
