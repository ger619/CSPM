class CreateRatings < ActiveRecord::Migration[7.2]
  def change
    create_table :ratings, id: :uuid do |t|
      t.integer :value
      t.references :ticket, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
