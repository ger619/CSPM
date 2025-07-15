class RemoveBoardIdFromTasks < ActiveRecord::Migration[7.2]
  def change
    remove_column :tasks, :board_id, :uuid
  end
end
