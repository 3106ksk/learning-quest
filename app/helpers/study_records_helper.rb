module StudyRecordsHelper
  def format_countdown(seconds)
    minutes, secs = seconds.divmod(60)
    format("%d:%02d", minutes, secs)
  end
end
