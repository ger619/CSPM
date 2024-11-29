class AddGroupwareIdToTicket < ActiveRecord::Migration[7.2]
  def change
    add_reference :tickets, :software,  foreign_key: true, type: :uuid
    add_reference :tickets, :groupware,  foreign_key: true, type: :uuid
  end
end
