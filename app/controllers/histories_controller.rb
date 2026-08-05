class HistoriesController < ApplicationController
  def index
    @records_by_date = history_records.recent_first.group_by { |record| record.started_at.to_date }
  end

  private

  def history_records
    Current.user.study_records.evaluated
  end
end
