class AddSlaResolutionToSlaTickets < ActiveRecord::Migration[7.2]
  def change
    add_column :sla_tickets, :sla_resolution_deadline, :string
  end
end
