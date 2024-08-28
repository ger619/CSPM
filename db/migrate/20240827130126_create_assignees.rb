class CreateAssignees < ActiveRecord::Migration[7.1]
  def change
    create_table :assignees, id: :uuid do |t|
      t.references :project, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
