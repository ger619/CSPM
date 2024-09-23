class AddStartAndEndDateToTickets < ActiveRecord::Migration[7.2]
  def change
    add_column :tickets, :start_date, :datetime
    add_column :tickets, :end_date, :datetime
    add_column :tickets, :topic, :string
    add_column :tickets, :description, :string
  end
end
