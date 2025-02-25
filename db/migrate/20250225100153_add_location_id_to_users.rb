class AddLocationIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :location_id, :uuid
  end
end
