class HistoriesController < ApplicationController
  def index
    @records_by_date =
      history_records
        .recent_first
        .group_by { |record| record.started_at.to_date }
        .transform_values { |records| records.reverse }
  end

  def show
    @study_record = history_records.find(params[:id])
    @evaluation = @study_record.evaluation
  rescue ActiveRecord::RecordNotFound
    redirect_to histories_path,
                danger: t(".not_found"),
                status: :see_other
  end

  private

  def history_records
    Current.user.study_records.evaluated
  end
end
