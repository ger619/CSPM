class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments, id: :uuid do |t|
      t.references :ticket, null: false, foreign_key: true, type: :uuid
      t.string :what
      t.string :why
      t.string :solution

      t.timestamps
    end
  end
end
