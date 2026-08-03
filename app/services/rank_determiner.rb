class RankDeterminer
  class InvalidTotalPointError < StandardError; end

  START_POINT = 1

  RANK_RANGES = {
    "a" => 6..7,
    "b" => 4..5,
    "c" => 3..3
  }.freeze

  def self.call(focus_point:, challenge_point:)
    new(
      focus_point: focus_point,
      challenge_point: challenge_point
    ).call
  end

  def initialize(focus_point:, challenge_point:)
    @focus_point = focus_point
    @challenge_point = challenge_point
  end

  def call
    total = START_POINT + focus_point + challenge_point

    RANK_RANGES.each do |code, range|
      return code if range.cover?(total)
    end

    raise InvalidTotalPointError, "Rankを判定できない合計点です: #{total}"
  end

  private

  attr_reader :focus_point, :challenge_point
end
