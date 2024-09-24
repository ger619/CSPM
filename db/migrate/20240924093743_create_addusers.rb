class CreateAddusers < ActiveRecord::Migration[7.2]
  def change
    create_table :addusers, id: :uuid do |t|
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
