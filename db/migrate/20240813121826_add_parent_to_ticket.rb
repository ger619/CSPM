class AddParentToTicket < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :parent_id, :uuid, null: true
  end
end
