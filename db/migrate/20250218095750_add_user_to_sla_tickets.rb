class AddUserToSlaTickets < ActiveRecord::Migration[7.2]
  def change
    add_reference :sla_tickets, :user, foreign_key: true, type: :uuid
  end
end
