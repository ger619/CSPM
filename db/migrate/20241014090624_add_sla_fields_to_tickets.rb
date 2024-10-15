class AddSlaFieldsToTickets < ActiveRecord::Migration[7.2]
  def change
    add_column :tickets, :initial_response_deadline, :datetime
    add_column :tickets, :target_repair_deadline, :datetime
    add_column :tickets, :resolution_deadline, :datetime
  end
end
