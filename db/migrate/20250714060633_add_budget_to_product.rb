class AddBudgetToProduct < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :budget, :string
  end
end
