class AddRankToStudyRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :study_records, :rank, :string

    add_check_constraint :study_records,
                         "rank IN ('a', 'b', 'c')",
                         name: "study_records_rank_allowed_values"

    add_check_constraint :study_records,
                         "status <> 'evaluated' OR rank IS NOT NULL",
                         name: "study_records_rank_required_when_evaluated"
  end
end
