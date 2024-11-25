class AddUniqueIdToTickets < ActiveRecord::Migration[7.2]
  def change
    add_column :tickets, :unique_id, :string
  end
end
