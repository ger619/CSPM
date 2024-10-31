class RemoveDefaultFromStatusInTickets < ActiveRecord::Migration[7.2]
  def change
    change_column_default :tickets, :status, from: 'new', to: nil
  end
end
