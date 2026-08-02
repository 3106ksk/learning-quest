require 'rails_helper'

RSpec.describe StudyRecord, type: :model do
  describe "#mark_as_evaluated!" do
    it "評価待ち以外の学習記録は評価済みに変更できない" do
      study_record = described_class.create!(
        user: create(:user),
        planned_minutes: 25,
        activity: "RSpecの学習",
        started_at: Time.current,
        status: :running
      )

      expect {
        study_record.mark_as_evaluated!
      }.to raise_error(RuntimeError, "評価待ちの記録だけ評価完了にできます")

      expect(study_record.reload).to be_running
    end
  end
end
