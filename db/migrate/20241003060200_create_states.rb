class CreateStates < ActiveRecord::Migration[7.2]
  def change
    create_table :states, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :task, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
