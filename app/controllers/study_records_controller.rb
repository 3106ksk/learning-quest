class StudyRecordsController < ApplicationController
  def index
  end

  def new
    @study_record = StudyRecord.new
  end

  def create
    @study_record = Current.user.study_records.build(
      study_record_params.merge(started_at: Time.current)
    )

    if @study_record.save
      redirect_to home_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
  end

  def destroy
  end

  private

  def study_record_params
    params.require(:study_record).permit(:planned_minutes)
  end
end
