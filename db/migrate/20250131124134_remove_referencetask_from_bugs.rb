class RemoveReferencetaskFromBugs < ActiveRecord::Migration[7.2]
  def change
    remove_column :bugs, :task_id, type: :uuid
    remove_column :bugs, :board_id, type: :uuid
  end
end
