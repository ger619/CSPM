class AddClientToUser < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :client,  foreign_key: true, type: :uuid
  end
end