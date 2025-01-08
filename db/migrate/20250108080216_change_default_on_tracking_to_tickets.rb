class ChangeDefaultOnTrackingToTickets < ActiveRecord::Migration[7.2]
  def change
    change_column_default :tickets, :update_count,  -1
  end
end
