class StudyRecordsController < ApplicationController
  layout "focus", only: :show

  before_action :set_study_record, only: %i[show pause resume]
  before_action :ensure_running, only: :pause
  before_action :ensure_paused, only: :resume

  def index
  end

  def new
    @study_record = StudyRecord.new
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

  def study_record_params
    params.require(:study_record).permit(:planned_minutes, :activity, :status)
  end
end
