class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events, id: :uuid do |t|
      t.references :ticket, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :event_type
      t.text :details

      t.timestamps
    end
  end
end
