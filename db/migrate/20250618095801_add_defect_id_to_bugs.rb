class AddDefectIdToBugs < ActiveRecord::Migration[7.2]
  def change
    add_reference :bugs, :defect, null: true, foreign_key: true, type: :uuid
  end
end
