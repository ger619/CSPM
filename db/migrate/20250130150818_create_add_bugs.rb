class CreateAddBugs < ActiveRecord::Migration[7.2]
  def change
    create_table :add_bugs, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :bug, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
