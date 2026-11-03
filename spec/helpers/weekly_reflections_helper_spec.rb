require "rails_helper"

RSpec.describe WeeklyReflectionsHelper, type: :helper do
  describe "#weekly_study_highlight" do
    it "始めやすく、続けやすくしたいのときは、学習全体と選んだ回に注目する" do
      expect(helper.weekly_study_highlight("easy_start")).to eq({ totals: true, focus: false, challenge: false })
    end

    it "集中して取り組みたいのときは、集中に注目する" do
      expect(helper.weekly_study_highlight("focus")).to eq({ totals: false, focus: true, challenge: false })
    end

    it "決めた内容に取り組みたいのときは、チャレンジに注目する" do
      expect(helper.weekly_study_highlight("challenge")).to eq({ totals: false, focus: false, challenge: true })
    end

    it "まだ決めていないのときは、どこにも注目しない" do
      expect(helper.weekly_study_highlight("undecided")).to eq({ totals: false, focus: false, challenge: false })
    end
  end
end
