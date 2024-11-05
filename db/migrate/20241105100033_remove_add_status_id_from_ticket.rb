class RemoveAddStatusIdFromTicket < ActiveRecord::Migration[7.2]
  def change
    remove_reference :tickets, :status, foreign_key: true, type: :uuid
  end
end
