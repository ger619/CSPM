class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products, id: :uuid do |t|
      t.string :name
      t.string :topic
      t.string :description
      t.date :start_date
      t.date :end_date
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
