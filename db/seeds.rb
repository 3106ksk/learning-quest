# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

focus_options = [
  {
    result_code: "focus_high",
    point: 3,
    position: 1,
    label: "いつも以上に集中できた",
    description: "選んだ時間を高い集中状態で使えた"
  },
  {
    result_code: "focus_mid",
    point: 2,
    position: 2,
    label: "集中して取り組めた",
    description: "学習内容に向き合って進められた"
  },
  {
    result_code: "focus_low",
    point: 1,
    position: 3,
    label: "途中で集中が切れたが取り組めた",
    description: "途切れても学習へ戻れた"
  }
]

focus_options.each do |attrs|
  option = FocusOption.find_or_initialize_by(result_code: attrs[:result_code])
  option.assign_attributes(attrs)
  option.save!
end

challenge_options = [
  {
    result_code: "challenge_high",
    point: 3,
    position: 1,
    label: "決めた内容を超えて進められた",
    description: "想定より多く取り組めた"
  },
  {
    result_code: "challenge_mid",
    point: 2,
    position: 2,
    label: "自分で決めた内容に取り組めた",
    description: "決めたことをひと通り進められた"
  },
  {
    result_code: "challenge_low",
    point: 1,
    position: 3,
    label: "難しくても決めたことに向き合えた",
    description: "うまくいかない部分があっても取り組み続けられた"
  }
]

challenge_options.each do |attrs|
  option = ChallengeOption.find_or_initialize_by(result_code: attrs[:result_code])
  option.assign_attributes(attrs)
  option.save!
end
