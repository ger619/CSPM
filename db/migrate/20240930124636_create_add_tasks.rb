class CreateAddTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :add_tasks, id: :uuid do |t|
      t.references :task, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
