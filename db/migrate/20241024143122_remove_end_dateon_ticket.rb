class RemoveEndDateonTicket < ActiveRecord::Migration[7.2]
  def change
    remove_column :tickets, :end_date, :date
  end
end
