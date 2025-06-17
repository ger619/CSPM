class AddProductIdToDefects < ActiveRecord::Migration[7.2]
  def change
    add_reference :defects, :product, null: false, foreign_key: true, type: :uuid
  end
end
