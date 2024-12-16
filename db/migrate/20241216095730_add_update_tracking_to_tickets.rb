class AddUpdateTrackingToTickets < ActiveRecord::Migration[6.1]
  def change
    add_column :tickets, :update_count, :integer, default: 0, null: false
    add_column :tickets, :last_updated_at, :datetime
  end
end