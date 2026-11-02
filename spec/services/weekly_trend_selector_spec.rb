require 'rails_helper'

RSpec.describe WeeklyTrendSelector do
  let(:statuses) { {} }
  let(:trends) do
    { study_count: :changed, study_days: :changed, focus: :changed, challenge: :changed }
      .merge(statuses)
      .to_h { |kind, status| [ kind, { kind: kind, status: status } ] }
  end

  subject(:kinds) do
    described_class.call(trends: trends, expectation: expectation).map { |trend| trend[:kind] }
  end

  describe "始めやすく、続けやすくしたい" do
    let(:expectation) { "easy_start" }

    context "判定の結果に関わらず" do
      it "学習回数、学習した日数の2件を返す" do
        expect(kinds).to eq([ :study_count, :study_days ])
      end
    end

    context "学習回数・学習した日数がどちらも週の途中の場合" do
      let(:statuses) { { study_count: :in_progress, study_days: :in_progress } }

      it "1件にまとめず2件を返す" do
        expect(kinds).to eq([ :study_count, :study_days ])
      end
    end
  end

  describe "集中して取り組みたい" do
    let(:expectation) { "focus" }

    context "集中の内訳が変化した場合" do
      it "集中の内訳の1件を返す" do
        expect(kinds).to eq([ :focus ])
      end
    end

    context "集中の内訳が前週なしの場合" do
      let(:statuses) { { focus: :no_previous } }

      it "ほかの傾向で埋めず、集中の内訳の1件を返す" do
        expect(kinds).to eq([ :focus ])
      end
    end
  end

  describe "決めた内容に取り組みたい" do
    let(:expectation) { "challenge" }

    context "チャレンジの内訳が記録が少ない場合" do
      let(:statuses) { { challenge: :too_few } }

      it "ほかの傾向で埋めず、チャレンジの内訳の1件を返す" do
        expect(kinds).to eq([ :challenge ])
      end
    end
  end

  describe "まだ決めていない" do
    let(:expectation) { "undecided" }

    context "4件とも比べられる場合" do
      it "集中の内訳、チャレンジの内訳の順に2件を返す" do
        expect(kinds).to eq([ :focus, :challenge ])
      end
    end

    context "集中の内訳が記録が少なく、チャレンジの内訳が変わらない場合" do
      let(:statuses) { { focus: :too_few, challenge: :unchanged } }

      it "比べられない集中を飛ばし、チャレンジの内訳、学習回数の2件を返す" do
        expect(kinds).to eq([ :challenge, :study_count ])
      end
    end

    context "4件とも比べられない場合" do
      let(:statuses) do
        { study_count: :no_previous, study_days: :no_previous, focus: :no_previous, challenge: :no_previous }
      end

      it "集中の内訳の1件を返す" do
        expect(kinds).to eq([ :focus ])
      end
    end
  end
end
