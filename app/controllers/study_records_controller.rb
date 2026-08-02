class StudyRecordsController < ApplicationController
  layout "focus", only: :show

  before_action :set_study_record, only: %i[show pause resume complete]
  before_action :ensure_running, only: :pause
  before_action :ensure_paused, only: :resume
  before_action :ensure_running_or_paused, only: :complete
  before_action :redirect_by_status, only: :show

  def index
  end

  def new
    active_record = Current.user.study_records.active.take

    if active_record
      destination = active_record.awaiting_evaluation? ? new_study_record_evaluation_path(active_record) : active_record

      redirect_to destination
    else
      @study_record = StudyRecord.new
    end
  end

  def show
  end

  def create
    @study_record = Current.user.study_records.build(
      study_record_params.merge(started_at: Time.current)
    )

    if @study_record.save
      redirect_to @study_record, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
  end

  def pause
    @study_record.start_pause!

    if turbo_frame_request?
      render partial: "study_records/countdown", locals: { study_record: @study_record }
    else
      redirect_to @study_record, status: :see_other
    end
  end

  def resume
    @study_record.start_resume!

    if turbo_frame_request?
      render partial: "study_records/countdown", locals: { study_record: @study_record }
    else
      redirect_to @study_record, status: :see_other
    end
  end

  def complete
    @study_record.complete!
    redirect_to new_study_record_evaluation_path(@study_record), status: :see_other
  end

  def destroy
  end

  private

  def set_study_record
    @study_record = Current.user.study_records.find(params[:id])
  end

  def ensure_running
    return if @study_record.running?

    redirect_to @study_record, status: :see_other
  end

  def ensure_paused
    return if @study_record.paused?

    redirect_to @study_record, status: :see_other
  end

  def ensure_running_or_paused
    return if @study_record.running? || @study_record.paused?

    redirect_to @study_record, status: :see_other
  end

  def redirect_by_status
    if @study_record.awaiting_evaluation?
      redirect_to new_study_record_evaluation_path(@study_record), status: :see_other
    elsif @study_record.evaluated?
      redirect_to home_path, status: :see_other
    end
  end

  def study_record_params
    params.require(:study_record).permit(:planned_minutes, :activity, :status)
  end
end
