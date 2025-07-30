class AddBudgetsToProduct < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :budget, :integer
  end
end
