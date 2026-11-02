require 'rails_helper'

RSpec.describe WeeklyTrendDeterminer do
  let(:focus_options) { build_stubbed_list(:focus_option, 3) }
  let(:challenge_options) { build_stubbed_list(:challenge_option, 3) }
  let(:previous_week_exists) { true }
  let(:week_finished) { true }
  let(:previous) { week }
  let(:current) { week }

  subject(:result) do
    described_class.call(
      weekly_study: {
        current: current,
        previous: previous,
        previous_week_exists: previous_week_exists,
        week_finished: week_finished
      }
    )
  end

  describe "学習回数" do
    context "前週に目標が無く、対象週が終わっていない場合" do
      let(:previous_week_exists) { false }
      let(:week_finished) { false }
      let(:current) { week(study_count: 2) }

      it "週の途中より先に、前週なしになる" do
        expect(result[:study_count]).to eq({ kind: :study_count, status: :no_previous })
      end
    end

    context "対象週が終わっていない場合" do
      let(:week_finished) { false }
      let(:previous) { week(study_count: 4) }
      let(:current) { week(study_count: 3) }

      it "週の途中として、今週ここまでの回数だけを返す" do
        expect(result[:study_count]).to eq({ kind: :study_count, status: :in_progress, current: 3 })
      end
    end

    context "前週0回、今週2回の場合" do
      let(:current) { week(study_count: 2) }

      it "変化として、前週と今週の回数を返す" do
        expect(result[:study_count]).to eq({ kind: :study_count, status: :changed, previous: 0, current: 2 })
      end
    end

    context "前週4回、今週5回の場合" do
      let(:previous) { week(study_count: 4) }
      let(:current) { week(study_count: 5) }

      it "1だけ違っても変化として返す" do
        expect(result[:study_count]).to eq({ kind: :study_count, status: :changed, previous: 4, current: 5 })
      end
    end

    context "前週も今週も4回の場合" do
      let(:previous) { week(study_count: 4) }
      let(:current) { week(study_count: 4) }

      it "変わらないとして、前週と今週の回数を返す" do
        expect(result[:study_count]).to eq({ kind: :study_count, status: :unchanged, previous: 4, current: 4 })
      end
    end
  end

  describe "学習した日数" do
    context "回数は同じで、日数だけが違う場合" do
      let(:previous) { week(study_count: 4, study_days: 2) }
      let(:current) { week(study_count: 4, study_days: 3) }

      it "回数とは別に、日数の変化を返す" do
        expect(result[:study_days]).to eq({ kind: :study_days, status: :changed, previous: 2, current: 3 })
        expect(result[:study_count]).to eq({ kind: :study_count, status: :unchanged, previous: 4, current: 4 })
      end
    end
  end

  describe "集中・チャレンジの内訳" do
    context "前週に目標が無い場合" do
      let(:previous_week_exists) { false }
      let(:current) { week(focus: [ 1, 1, 1 ]) }

      it "前週なしになる" do
        expect(result[:focus]).to eq({ kind: :focus, status: :no_previous })
      end
    end

    context "今週、工夫を選んだ回が0回の場合" do
      let(:previous) { week(focus: [ 2, 2, 1 ]) }
      let(:current) { week(focus: [ 0, 0, 0 ]) }

      it "記録が少ないより先に、工夫を選んだ回なしになる" do
        expect(result[:focus]).to eq({ kind: :focus, status: :no_selection })
      end
    end

    context "前週の工夫を選んだ回が2回の場合" do
      let(:previous) { week(focus: [ 1, 1, 0 ]) }
      let(:current) { week(focus: [ 2, 2, 1 ]) }

      it "記録が少ないとして、前週と今週の回数を返す" do
        expect(result[:focus]).to eq({ kind: :focus, status: :too_few, previous_total: 2, current_total: 5 })
      end
    end

    context "前週も今週も工夫を選んだ回が3回の場合" do
      let(:previous) { week(focus: [ 1, 1, 1 ]) }
      let(:current) { week(focus: [ 1, 1, 1 ]) }

      it "記録が少ないにならず、割合で比べる" do
        expect(result[:focus]).to eq({ kind: :focus, status: :unchanged, previous_total: 3, current_total: 3 })
      end
    end

    context "割合の差がちょうど35ポイントの場合（前週12回中7回、今週15回中14回）" do
      let(:previous) { week(focus: [ 7, 3, 2 ]) }
      let(:current) { week(focus: [ 14, 0, 1 ]) }

      it "変化として、選択肢と前週・今週の何回中何回を返す" do
        expect(result[:focus]).to eq(
          {
            kind: :focus,
            status: :changed,
            option: focus_options[0],
            previous_total: 12,
            previous_count: 7,
            current_total: 15,
            current_count: 14
          }
        )
      end
    end

    context "割合の差が35ポイント未満の場合（前週4回中2回、今週13回中2回）" do
      let(:previous) { week(focus: [ 2, 1, 1 ]) }
      let(:current) { week(focus: [ 2, 6, 5 ]) }

      it "変わらないとして、前週と今週の回数を返す" do
        expect(result[:focus]).to eq({ kind: :focus, status: :unchanged, previous_total: 4, current_total: 13 })
      end
    end

    context "減った方向に35ポイント以上の場合（前週3回中3回、今週3回中1回）" do
      let(:previous) { week(focus: [ 3, 0, 0 ]) }
      let(:current) { week(focus: [ 1, 1, 1 ]) }

      it "変化として、減った選択肢を返す" do
        expect(result[:focus]).to eq(
          {
            kind: :focus,
            status: :changed,
            option: focus_options[0],
            previous_total: 3,
            previous_count: 3,
            current_total: 3,
            current_count: 1
          }
        )
      end
    end

    context "対象週が終わっていない場合" do
      let(:week_finished) { false }
      let(:previous) { week(focus: [ 7, 3, 2 ]) }
      let(:current) { week(focus: [ 14, 0, 1 ]) }

      it "週の途中でも前週と比べる" do
        expect(result[:focus]).to include(status: :changed, option: focus_options[0])
      end
    end

    context "チャレンジの内訳の場合" do
      let(:previous) { week(focus: [ 7, 3, 2 ]) }
      let(:current) { week(focus: [ 14, 0, 1 ]) }

      it "集中と同じルールで判定する" do
        expect(result[:challenge]).to eq(
          {
            kind: :challenge,
            status: :changed,
            option: challenge_options[0],
            previous_total: 12,
            previous_count: 7,
            current_total: 15,
            current_count: 14
          }
        )
      end
    end
  end

  def week(study_count: 0, study_days: 0, focus: [ 0, 0, 0 ], challenge: focus)
    {
      study_count: study_count,
      study_days: study_days,
      selected_count: focus.sum,
      focus: focus_options.zip(focus).to_h,
      challenge: challenge_options.zip(challenge).to_h
    }
  end
end
