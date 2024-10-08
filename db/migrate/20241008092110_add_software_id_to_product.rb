class AddSoftwareIdToProduct < ActiveRecord::Migration[7.2]
  def change
    add_reference :products, :software, foreign_key: true, type: :uuid
  end
end
