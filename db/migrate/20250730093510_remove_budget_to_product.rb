class RemoveBudgetToProduct < ActiveRecord::Migration[7.2]
  def change
    remove_column :products, :budget, :string
  end
end
