class CreateBoards < ActiveRecord::Migration[7.2]
  def change
    create_table :boards, id: :uuid do |t|
      t.string :status
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
