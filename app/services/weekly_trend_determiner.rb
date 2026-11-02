class WeeklyTrendDeterminer
  def self.call(weekly_study:)
    new(weekly_study: weekly_study).call
  end

  def initialize(weekly_study:)
    @weekly_study = weekly_study
  end

  def call
    {}
  end

  private

  attr_reader :weekly_study
end
