class CreateGroupwares < ActiveRecord::Migration[7.2]
  def change
    create_table :groupwares, id: :uuid do |t|
      t.string :name
      t.references :software, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
