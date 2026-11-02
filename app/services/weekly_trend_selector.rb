class WeeklyTrendSelector
  TRENDS_BY_EXPECTATION = {
    "easy_start" => [ :study_count, :study_days ],
    "focus" => [ :focus ],
    "challenge" => [ :challenge ]
  }.freeze

  UNDECIDED_ORDER = [ :focus, :challenge, :study_count, :study_days ].freeze
  COMPARABLE_STATUSES = [ :changed, :unchanged ].freeze
  MAXIMUM_COUNT = 2

  def self.call(trends:, expectation:)
    new(trends: trends, expectation: expectation).call
  end

  def initialize(trends:, expectation:)
    @trends = trends
    @expectation = expectation
  end

  def call
    if expectation == "undecided"
      select_comparable
    else
      TRENDS_BY_EXPECTATION.fetch(expectation).map { |kind| trends[kind] }
    end
  end

  private

  attr_reader :trends, :expectation

  def select_comparable
    comparable = UNDECIDED_ORDER.map { |kind| trends[kind] }.select { |trend| COMPARABLE_STATUSES.include?(trend[:status]) }
    return [ trends[:focus] ] if comparable.empty?

    comparable.first(MAXIMUM_COUNT)
  end
end
