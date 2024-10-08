class AddClientToProduct < ActiveRecord::Migration[7.2]
  def change
    add_reference :products, :client,  foreign_key: true, type: :uuid
  end
end
