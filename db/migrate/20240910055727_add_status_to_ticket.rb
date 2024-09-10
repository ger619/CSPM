class AddStatusToTicket < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :status, :string, default: 'new'
  end
end
