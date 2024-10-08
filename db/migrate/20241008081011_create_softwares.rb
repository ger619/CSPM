class CreateSoftwares < ActiveRecord::Migration[7.2]
  def change
    create_table :softwares, id: :uuid do |t|
      t.string :name
      t.string :description
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
