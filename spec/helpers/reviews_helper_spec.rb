require "rails_helper"

RSpec.describe ReviewsHelper, type: :helper do
  include ActiveSupport::Testing::TimeHelpers

  let(:learning_skill) { build_stubbed(:learning_skill, name: "問題を解く前に制限時間を決める") }
  let(:weekly_reflection) do
    build_stubbed(:weekly_reflection, learning_skill: learning_skill, week_start_on: Date.new(2026, 10, 19))
  end

  describe "#review_trend_items" do
    context "学習回数が変化した場合" do
      it "前週と今週の期間と回数の文を返す" do
        trends = [ { kind: :study_count, status: :changed, previous: 4, current: 5 } ]

        expect(helper.review_trend_items(trends, weekly_reflection)).to eq([
          { label: "学習回数", sentence: "この目標の学習は、前週（10/12〜10/18）4回、今週（10/19〜10/25）5回でした。" }
        ])
      end
    end

    context "学習回数が変わらない場合" do
      it "前週も今週も同じ回数だったという文を返す" do
        trends = [ { kind: :study_count, status: :unchanged, previous: 4, current: 4 } ]

        expect(helper.review_trend_items(trends, weekly_reflection)).to eq([
          { label: "学習回数", sentence: "この目標の学習は、前週も今週も4回でした。" }
        ])
      end
    end

    context "学習した日数が変化した場合" do
      it "前週と今週の期間と日数の文を返す" do
        trends = [ { kind: :study_days, status: :changed, previous: 2, current: 3 } ]

        expect(helper.review_trend_items(trends, weekly_reflection)).to eq([
          { label: "学習した日", sentence: "学習した日は、前週（10/12〜10/18）2日、今週（10/19〜10/25）3日でした。" }
        ])
      end
    end

    context "学習した日数が変わらない場合" do
      it "前週も今週も同じ日数だったという文を返す" do
        trends = [ { kind: :study_days, status: :unchanged, previous: 3, current: 3 } ]

        expect(helper.review_trend_items(trends, weekly_reflection)).to eq([
          { label: "学習した日", sentence: "学習した日は、前週も今週も3日でした。" }
        ])
      end
    end

    context "学習回数・日数がどちらも週の途中の場合" do
      it "1件にまとめ、週の始まりから今日までの回数と日数の文を返す" do
        trends = [
          { kind: :study_count, status: :in_progress, current: 3 },
          { kind: :study_days, status: :in_progress, current: 2 }
        ]

        travel_to Time.zone.local(2026, 10, 21, 12, 0, 0) do
          expect(helper.review_trend_items(trends, weekly_reflection)).to eq([
            {
              label: "学習回数・日数",
              sentence: "今週はまだ途中のため、学習回数・日数は週が終わってから前週と比べます。今週（10/19〜10/21）は、ここまで3回・2日です。"
            }
          ])
        end
      end
    end

    context "学習回数・日数がどちらも前週なしの場合" do
      it "1件にまとめ、前週と比べない理由の文を返す" do
        trends = [
          { kind: :study_count, status: :no_previous },
          { kind: :study_days, status: :no_previous }
        ]

        expect(helper.review_trend_items(trends, weekly_reflection)).to eq([
          { label: "学習回数・日数", sentence: "この目標は今週から始めたため、前週とは比べていません。" }
        ])
      end
    end

    context "集中の内訳が変化した場合" do
      it "変化した選択肢と、前週・今週の何回中何回かの文を返す" do
        option = build_stubbed(:focus_option, label: "途中で集中が切れたが取り組めた")
        trends = [
          {
            kind: :focus, status: :changed, option: option,
            previous_total: 4, previous_count: 1, current_total: 5, current_count: 4
          }
        ]

        expect(helper.review_trend_items(trends, weekly_reflection)).to eq([
          {
            label: "集中",
            sentence: "「問題を解く前に制限時間を決める」を選んだ回の「途中で集中が切れたが取り組めた」は、前週4回中1回、今週5回中4回でした。"
          }
        ])
      end
    end

    context "集中の内訳が変わらない場合" do
      it "前週と今週の回数と、大きな違いが無いという文を返す" do
        trends = [ { kind: :focus, status: :unchanged, previous_total: 4, current_total: 5 } ]

        expect(helper.review_trend_items(trends, weekly_reflection)).to eq([
          {
            label: "集中",
            sentence: "「問題を解く前に制限時間を決める」を選んだ回の集中は、前週（4回）と今週（5回）で大きな違いはありませんでした。"
          }
        ])
      end
    end

    context "チャレンジの記録が少ない場合" do
      it "前週と今週の回数と、比べる条件の文を返す" do
        trends = [ { kind: :challenge, status: :too_few, previous_total: 2, current_total: 5 } ]

        expect(helper.review_trend_items(trends, weekly_reflection)).to eq([
          {
            label: "チャレンジ",
            sentence: "「問題を解く前に制限時間を決める」を選んだ回は、前週2回、今週5回でした。どちらの週も3回以上あるときに、前週と比べます。"
          }
        ])
      end
    end

    context "集中が前週なしの場合" do
      it "前週と比べない理由の文を返す" do
        trends = [ { kind: :focus, status: :no_previous } ]

        expect(helper.review_trend_items(trends, weekly_reflection)).to eq([
          { label: "集中", sentence: "この目標は今週から始めたため、前週とは比べていません。" }
        ])
      end
    end

    context "集中で、この学習スキルを選んだ回が無い場合" do
      it "集中を比べる条件の文を返す" do
        trends = [ { kind: :focus, status: :no_selection } ]

        expect(helper.review_trend_items(trends, weekly_reflection)).to eq([
          { label: "集中", sentence: "集中の様子は、この学習スキルを選んだ回があるときに前週と比べます。" }
        ])
      end
    end

    context "チャレンジで、この学習スキルを選んだ回が無い場合" do
      it "チャレンジを比べる条件の文を返す" do
        trends = [ { kind: :challenge, status: :no_selection } ]

        expect(helper.review_trend_items(trends, weekly_reflection)).to eq([
          { label: "チャレンジ", sentence: "チャレンジの様子は、この学習スキルを選んだ回があるときに前週と比べます。" }
        ])
      end
    end
  end

  describe "#review_continuation_sentence" do
    context "今週この学習スキルを選んだ回があり、最初の週の場合" do
      it "今週選んだ回数の文だけを返す" do
        sentence = helper.review_continuation_sentence(weekly_reflection, selected_count: 3, skill_total: { weeks: 1, count: 3 })

        expect(sentence).to eq("「問題を解く前に制限時間を決める」を今週は3回選びました。")
      end
    end

    context "今週この学習スキルを選んだ回が0回の場合" do
      it "選んだ学習が無かったという文を返す" do
        sentence = helper.review_continuation_sentence(weekly_reflection, selected_count: 0, skill_total: { weeks: 1, count: 0 })

        expect(sentence).to eq("今週は「問題を解く前に制限時間を決める」を選んだ学習はありませんでした。")
      end
    end

    context "この学習スキルを対象にした週が2週以上ある場合" do
      it "今週の文に続けて、通算の週数と回数の文を返す" do
        sentence = helper.review_continuation_sentence(weekly_reflection, selected_count: 4, skill_total: { weeks: 2, count: 7 })

        expect(sentence).to eq("「問題を解く前に制限時間を決める」を今週は4回選びました。振り返りの対象にしてから、通算2週・7回です。")
      end
    end
  end
end
