class StudyRecordsController < ApplicationController
  def index
  end

  def new
    @study_record = StudyRecord.new
  end

  def show
    @study_record = Current.user.study_records.find(params[:id])
  end

  def create
    Rails.logger.info "=== 学習記録の作成リクエスト開始 ==="

    @study_record = Current.user.study_records.build(
      study_record_params.merge(started_at: Time.current)
    )

    Rails.logger.info "バリデーション実行前"
    if @study_record.save
      Rails.logger.info "学習記録の保存成功: id=#{@study_record.id}"
      redirect_to @study_record, status: :see_other
    else
      Rails.logger.info "バリデーションエラー: この#{@study_record.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end

  def update
  end

  def destroy
  end

  private

  def study_record_params
    params.require(:study_record).permit(:planned_minutes, :activity, :status)
  end
end
