class AddPositionToTasks < ActiveRecord::Migration[7.2]
  def change
    add_column :tasks, :position, :integer
    Task.order(:updated_at).each.with_index(1) do |task, index|
      task.update_column :position, index
    end
    add_column :boards, :position, :integer
    Board.order(:updated_at).each.with_index(1) do |board, index|
      board.update_column :position, index
    end
  end
end
