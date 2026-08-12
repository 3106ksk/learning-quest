require 'rails_helper'

RSpec.describe "StudyRecords", type: :request do
  let(:user) { create(:user) }
  let(:study_record) do
    StudyRecord.create!(
      user: user,
      planned_minutes: 25,
        activity: "RSpecの学習",
        started_at: Time.current,
        status: study_record_status,
        rank: study_record_status == :evaluated ? :a : nil,
        current_pause_started_at: study_record_status == :paused ? Time.current : nil
    )
  end

  before do
    sign_in(user)
  end

  describe "GET /study_records/:id" do
    [ :running, :paused ].each do |status|
      context "学習記録が#{status}の場合" do
        let(:study_record_status) { status }

        it "学習画面を表示する" do
          get study_record_path(study_record)

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "学習記録が評価待ちの場合" do
      let(:study_record_status) { :awaiting_evaluation }

      it "評価入力画面へ遷移する" do
        get study_record_path(study_record)

        expect(response).to redirect_to(new_study_record_evaluation_path(study_record))
        expect(response).to have_http_status(:see_other)
      end
    end

    context "学習記録が評価済みの場合" do
      let(:study_record_status) { :evaluated }

      it "評価結果画面へ遷移する" do
        get study_record_path(study_record)

        expect(response).to redirect_to(study_record_evaluation_path(study_record))
        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe "GET /study_records/new" do
    it "評価済みの学習記録があっても新規学習フォームを表示する" do
      StudyRecord.create!(
        user: user,
        planned_minutes: 25,
        activity: "完了した学習",
        started_at: Time.current,
        status: :evaluated,
        rank: :a
      )

      get new_study_record_path

      expect(response).to have_http_status(:ok)
    end
  end

  def sign_in(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "Password123!"
    }
  end
end
