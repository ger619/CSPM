class AddScriptIdToProduct < ActiveRecord::Migration[7.2]
  def change
    add_reference :products, :script,  foreign_key: true, type: :uuid
  end
end
