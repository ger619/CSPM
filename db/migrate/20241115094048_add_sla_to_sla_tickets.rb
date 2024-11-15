class AddSlaToSlaTickets < ActiveRecord::Migration[7.2]
  def change
    add_column :sla_tickets, :sla_target_response_deadline, :string
  end
end
