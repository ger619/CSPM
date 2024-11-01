class AddStatusIdToTicket < ActiveRecord::Migration[7.2]
  def change
    add_reference :tickets, :status, foreign_key: true, type: :uuid
  end
end
