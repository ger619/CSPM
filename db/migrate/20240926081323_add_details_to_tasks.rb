class AddDetailsToTasks < ActiveRecord::Migration[7.2]
  def change
    add_column :tasks, :start_date, :date
    add_column :tasks, :end_date, :date
    add_reference :tasks, :board, null: false, foreign_key: true, type: :uuid

  end
end
