class CreateAjoinTableForProductAndScript < ActiveRecord::Migration[7.2]
  def change
    create_join_table :products, :scripts, column_options: { type: :uuid }   do |t|
      t.index [:product_id, :script_id]
      t.index [:script_id, :product_id]
    end
  end
end
