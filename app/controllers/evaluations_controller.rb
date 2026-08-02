class EvaluationsController < ApplicationController
  before_action :set_study_record
  before_action :ensure_awaiting_evaluation, only: :new

  def new
    @evaluation = Evaluation.new
    @evaluation.study_record = @study_record
    set_evaluation_options
  end

  def create
    @evaluation = Evaluation.new(evaluation_params)
    @evaluation.study_record = @study_record

    if @evaluation.save
      redirect_to home_path, status: :see_other
    else
      set_evaluation_options
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_study_record
    @study_record = Current.user.study_records.find(params[:study_record_id])
  end

  def ensure_awaiting_evaluation
    return if @study_record.awaiting_evaluation?

    redirect_to @study_record, status: :see_other
  end

  def evaluation_params
    params.require(:evaluation).permit(:focus_option_id, :challenge_option_id)
  end

  def set_evaluation_options
    @focus_options = FocusOption.display_order
    @challenge_options = ChallengeOption.display_order
  end
end
