class AddPrerequisiteToTask < ActiveRecord::Migration[7.2]
  def change
    add_reference :tasks, :tasks, null: true, foreign_key: true, type: :uuid
  end
end
