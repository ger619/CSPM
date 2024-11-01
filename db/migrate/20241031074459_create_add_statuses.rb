class CreateAddStatuses < ActiveRecord::Migration[7.2]
  def change
    create_table :add_statuses, id: :uuid do |t|
      t.references :ticket, null: false, foreign_key: true, type: :uuid
      t.references :status, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
