class CreateIssues < ActiveRecord::Migration[7.1]
  def change
    create_table :issues, id: :uuid do |t|
      t.string :subject

      t.references :ticket, null: false, foreign_key: true, type: :uuid
      t.references :project, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
