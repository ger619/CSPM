class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages, id: :uuid do |t|
      t.text :content
      t.string :message_type
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :task, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
