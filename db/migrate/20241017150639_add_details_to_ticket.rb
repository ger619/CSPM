class AddDetailsToTicket < ActiveRecord::Migration[7.2]
  def change
    add_column :tickets, :end_date, :date
    add_column :tickets, :remarks, :string
  end
end
