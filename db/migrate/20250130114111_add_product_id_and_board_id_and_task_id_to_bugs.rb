class AddProductIdAndBoardIdAndTaskIdToBugs < ActiveRecord::Migration[7.2]
  def change
    add_reference :bugs, :product, null: false, foreign_key: true, type: :uuid
    add_reference :bugs, :board, null: false, foreign_key: true, type: :uuid
  end
end
