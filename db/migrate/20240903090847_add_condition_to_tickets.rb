class AddConditionToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :condition, :integer, default: 0
  end
end
