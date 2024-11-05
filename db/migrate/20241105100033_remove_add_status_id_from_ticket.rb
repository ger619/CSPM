class RemoveAddStatusIdFromTicket < ActiveRecord::Migration[7.2]
  def change
    remove_column :tickets, :status_id, :uuid
  end
end
