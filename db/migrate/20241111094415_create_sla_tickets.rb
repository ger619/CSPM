class CreateSlaTickets < ActiveRecord::Migration[7.2]
  def change
    create_table :sla_tickets, id: :uuid do |t|
      t.references :ticket, null: false, foreign_key: true, type: :uuid
      t.string :sla_status

      t.timestamps
    end
  end
end
