class CreateJoinTableTasksStatus < ActiveRecord::Migration[7.2]
  def change
    create_join_table :tasks, :statuses, column_options: { type: :uuid } do |t|
      t.index [:task_id, :status_id]
      t.index [:status_id, :task_id]
    end
  end
end
