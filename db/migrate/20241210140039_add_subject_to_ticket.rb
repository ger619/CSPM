class AddSubjectToTicket < ActiveRecord::Migration[7.2]
  def change
    add_column :tickets, :subject, :string
  end
end
