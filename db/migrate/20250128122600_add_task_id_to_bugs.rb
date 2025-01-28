class AddTaskIdToBugs < ActiveRecord::Migration[7.2]
  def change
    add_reference :bugs, :task, type: :uuid, null: false, foreign_key: true
  end
end
