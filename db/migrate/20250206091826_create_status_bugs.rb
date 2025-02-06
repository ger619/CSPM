class CreateStatusBugs < ActiveRecord::Migration[7.2]
  def change
    create_table :status_bugs, id: :uuid do |t|
      t.references :bug, null: false, foreign_key: true, type: :uuid
      t.references :status, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
